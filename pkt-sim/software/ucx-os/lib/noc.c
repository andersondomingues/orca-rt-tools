/**
  2 bytes   2 bytes   2 bytes   2 bytes   2 bytes   2 bytes   2 bytes   2 bytes       ....
 --------------------------------------------------------------------------------------------------
 |tgt_cpu  |payload  |src_cpu  |src_port |tgt_port |msg_size |seq      |channel  |  ... data ...  |
 --------------------------------------------------------------------------------------------------
 *
 * The platform should include the following macros:
 *
 * NOC_INTERCONNECT			intra-chip interconnection type
 * CPU_ID				a unique sequential number for each core (unused, see ucx_noc_cpuid(void))
 * NOC_WIDTH				number of columns of the 2D mesh
 * NOC_HEIGHT				number of rows of the 2D mesh
 * NOC_PACKET_SIZE			packet size (in 16 bit flits)
 * NOC_PACKET_SLOTS			number of slots in the shared packet queue per core
 */

#include <ucx.h>


// externs
uint16_t pktdrv_ports[MAX_TASKS];
struct queue_s *pktdrv_tqueue[MAX_TASKS];
struct queue_s *pktdrv_queue;
int32_t (*pktdrv_callback)(uint16_t *buf);

// Gets the address of the current NoC node. Nodes are identified by
// their XY address, which is compressed in a 32-bit word such that
// XY = (X << 16) | Y;
uint32_t ucx_noc_cpu_id(void)
{
  return _ddma_node_addr();
}

// Initializes a queue of packets using one of the available ports. May a
// port be unavailable, the requested queue initialization will fail
// with ERR_COMM_UNFEASIBLE.
uint32_t ucx_noc_comm_create(uint16_t port)
{
  int task_id = ucx_task_id();

  // check whether this task has allocated a port before
  if (pktdrv_tqueue[task_id] != NULL)
    return ERR_COMM_UNFEASIBLE;

  // port already in use by another task
  for (int k = 0; k < MAX_TASKS; k++)
    if (pktdrv_ports[k] == port)
      return ERR_COMM_ERROR;

  // add a new queue to receive packets for that task
  pktdrv_tqueue[task_id] = ucx_queue_create(NOC_PACKET_SLOTS);

  // if we cannot create a new queue due to unavailable memory
  // space, return ERR_OUT_OF_MEMORY
  if (pktdrv_tqueue[task_id] == 0)
    return ERR_OUT_OF_MEMORY;

  // connect the port to the task and return ERR_OK
  pktdrv_ports[task_id] = port;
  return ERR_OK;
}

// Destroys a connection, removing the
uint32_t ucx_noc_comm_destroy(uint16_t port)
{
  int task_id = ucx_task_id();
  // int32_t status;

  // status = _di();
  _di();

  // removes all elements from the comm queue, adding them
  // to the queue of shared packets
  while (ucx_queue_count(pktdrv_tqueue[task_id]))
    ucx_queue_enqueue(pktdrv_queue, ucx_queue_dequeue(pktdrv_tqueue[task_id]));

  _ei();

  // check whether the comm queue was gracefully destroyed. If not,
  // return ERR_COMM_ERROR
  if (ucx_queue_destroy(pktdrv_tqueue[task_id]))
    return ERR_COMM_ERROR;

  pktdrv_ports[task_id] = 0;
  return ERR_OK;
}

// forwards isr to driver routine 
void irq2_handler(void){
  noc_driver_isr();
};

// Initializes the driver
void noc_driver_init(void)
{
  _ddma_init();

  printf("noc_driver_init(): this is core #%d\n", ucx_noc_cpu_id());
  printf("noc_driver_init(): noc queue init, %d packets\n", NOC_PACKET_SLOTS);
  
  pktdrv_queue = ucx_queue_create(NOC_PACKET_SLOTS);
  
  if (pktdrv_queue == NULL){
    printf("noc_driver_init(): unable to create packet queue\n");
    printf("noc_driver_init(): noc driver irq won't be registered\n");
  } else {
    for (int32_t i = 0; i < MAX_TASKS; i++){
      pktdrv_ports[i] = 0;
    }
    printf("noc_driver_init(): noc driver isr registered 0x%0x\n", &irq2_handler);
  }
}


/**
 * @brief NoC driver: network interface interrupt service routine.
 *
 * This routine is called by the second level of interrupt handling. An interrupt from the network
 * interface means a full packet has arrived. The packet header is decoded and the target port is
 * identified. A reference to an empty packet is removed from the pool of buffers (packets), the
 * contents of the empty packet are filled with flits from the hardware queue and the reference is
 * put on the target task (associated to a port) queue of packets. There is one queue per task of
 * configurable size (individual queues are elastic if size is zero, limited to the size of free
 * buffer elements from the common pool). If port 0xffff (65535) is used as the target, the packet
 * is passed to a callback. This mechanism can be used to build custom OS functions (such as user
 * defined protocols, RPC or remote system calls). Port 0 is used as a discard function, for testing
 * purposes.
 */

void noc_driver_isr()
{
  // Since we know the size of the received packet, we ask the driver to copy only
  // the necessary bytes. The size of the packet is written by the NI to the
  // sig_recv_status signal (see drv). We need to know the size of the packet before
  // receiving it, so it can be flushed case no more room is available
  uint32_t* pkt_ptr  = _ddma_recv_ptr_out();

  // get rid of packets which address is not the same of this cpu
  if (pkt_ptr[PKT_TARGET_CPU] != ucx_noc_cpu_id())
  {
    printf("noc_driver_isr(): packet should not arrive at this node, target was %d", 
      pkt_ptr[PKT_TARGET_CPU]);

    // return pointer to the queue
    ucx_queue_enqueue(pktdrv_queue, pkt_ptr);
    return;
  }

  // get the queue associated to the port indicated in the packet
  int k;
  for (k = 0; k < MAX_TASKS; k++)
    if (pktdrv_ports[k] == pkt_ptr[PKT_TARGET_PORT])
      break;

  // check whether the task has room for more packets in that queue
  if (ucx_queue_enqueue(pktdrv_tqueue[k], pkt_ptr))
  {
    printf("noc_driver_isr(): task (on port %d) cannot receive more packets, dropping", 
      pkt_ptr[PKT_TARGET_PORT]);
    ucx_queue_enqueue(pktdrv_queue, pkt_ptr);
  }
}

/**
 * @brief Probes for a message from a task.

 * @return channel of the first message that is waiting in queue (a value >= 0), ERR_COMM_EMPTY when no messages are
 * waiting in queue, ERR_COMM_UNFEASIBLE when no message queue (comm) was created.
 *
 * Asynchronous communication is possible using this primitive, as it first tests if there is data
 * ready for reception with ucx_noc_recv() which is a blocking primitive. The main advantage of using ucx_noc_recvprobe()
 * along with ucx_noc_recv() is that a selective receive can be performed in the right communication channel. As
 * the message is waiting at the beginning of the queue, a receive on its channel can be used to process the
 * messages in order, avoiding packet loss.
 */
int32_t ucx_noc_recvprobe(void)
{
  uint16_t id;
  int32_t k;
  uint16_t *buf_ptr;

  id = ucx_task_id();
  if (pktdrv_tqueue[id] == NULL)
    return ERR_COMM_UNFEASIBLE;

  k = ucx_queue_count(pktdrv_tqueue[id]);
  if (k)
  {
    buf_ptr = ucx_queue_peek(pktdrv_tqueue[id]);
    if (buf_ptr)
      if (buf_ptr[PKT_CHANNEL] != 0xffff)
        return buf_ptr[PKT_CHANNEL];
  }

  return ERR_COMM_EMPTY;
}

/**
 * @brief Receives a message from a task (blocking receive).
 *
 * @param source_cpu is a pointer to a variable which will hold the source cpu
 * @param source_port is a pointer to a variable which will hold the source port
 * @param buf is a pointer to a buffer to hold the received message
 * @param size a pointer to a variable which will hold the size (in bytes) of the received message
 * @param channel is the selected message channel of this message (must be the same as in the sender)
 *
 * @return ERR_OK when successful, ERR_COMM_UNFEASIBLE when no message queue (comm) was
 * created and ERR_SEQ_ERROR when received packets arrive out of order, so the message
 * is corrupted.
 *
 * A message is build from packets received on the ni_isr() routine. Packets are decoded and
 * combined in a complete message, returning the message, its size and source identification
 * to the calling task. The buffer where the message will be stored must be large enough or
 * we will have a problem that may not be noticed before its too late.
 */
int32_t ucx_noc_recv(uint16_t *source_cpu, uint16_t *source_port, int8_t *buf, uint16_t *size, uint16_t channel)
{
  uint16_t id, seq = 0, packet = 0, packets, payload_bytes;
  // uint32_t status;
  int32_t i, k, p = 0, error = ERR_OK;
  uint16_t *buf_ptr;

  // printf("ucx_noc_recv: 0x%x\n", (uint32_t)buf);

  id = ucx_task_id();

  if (pktdrv_tqueue[id] == NULL)
    return ERR_COMM_UNFEASIBLE;

  while (1)
  {
    k = ucx_queue_count(pktdrv_tqueue[id]);
    if (k)
    {
      buf_ptr = ucx_queue_peek(pktdrv_tqueue[id]);
      if (buf_ptr)
        if (buf_ptr[PKT_CHANNEL] == channel && buf_ptr[PKT_SEQ] == seq + 1)
          break;

      // status = _di();
      _di();
      buf_ptr = ucx_queue_dequeue(pktdrv_tqueue[id]);
      ucx_queue_enqueue(pktdrv_tqueue[id], buf_ptr);
      _ei();
    }
  }

  // printf("queue size: 0x%x\n", ucx_queue_count(pktdrv_tqueue[id]);

  // status = _di();
  _di();
  buf_ptr = ucx_queue_dequeue(pktdrv_tqueue[id]);
  _ei();

  *source_cpu = buf_ptr[PKT_SOURCE_CPU];
  *source_port = buf_ptr[PKT_SOURCE_PORT];
  *size = buf_ptr[PKT_MSG_SIZE];
  seq = buf_ptr[PKT_SEQ];

  // 4 bytes per flit
  uint32_t packet_size = PKT_MSG_SIZE * 4;

  payload_bytes = (packet_size - PKT_HEADER_SIZE) * sizeof(uint16_t);
  packets = (*size % payload_bytes == 0) ? (*size / payload_bytes) : (*size / payload_bytes + 1);

  while (++packet < packets)
  {
    if (buf_ptr[PKT_SEQ] != seq++)
      error = ERR_SEQ_ERROR;

    for (i = PKT_HEADER_SIZE; i < packet_size; i++)
    {
      buf[p++] = (uint8_t)(buf_ptr[i] >> 8);
      buf[p++] = (uint8_t)(buf_ptr[i] & 0xff);
    }
    // status = _di();
    _di();
    ucx_queue_enqueue(pktdrv_queue, buf_ptr);
    _ei();

    i = 0;
    while (1)
    {
      k = ucx_queue_count(pktdrv_tqueue[id]);
      if (k)
      {
        buf_ptr = ucx_queue_peek(pktdrv_tqueue[id]);
        if (buf_ptr)
          if (buf_ptr[PKT_CHANNEL] == channel && buf_ptr[PKT_SEQ] == seq)
            break;

        // status = _di();
        _di();
        buf_ptr = ucx_queue_dequeue(pktdrv_tqueue[id]);
        ucx_queue_enqueue(pktdrv_tqueue[id], buf_ptr);
        _ei();
        if (i++ > NOC_PACKET_SLOTS << 3)
          break;
      }
    }
    // status = _di();
    _di();
    buf_ptr = ucx_queue_dequeue(pktdrv_tqueue[id]);
    _ei();
  }

  if (buf_ptr[PKT_SEQ] != seq++)
    error = ERR_SEQ_ERROR;

  // TODO: treat endianess up to the size of the packet
  // for (i = PKT_HEADER_SIZE; i < packet_size && p < *size; i++){
  for (i = PKT_HEADER_SIZE; i < buf_ptr[PKT_PAYLOAD] + 1 && p < *size; i++)
  {
    buf[p++] = (uint8_t)(buf_ptr[i] >> 8);
    buf[p++] = (uint8_t)(buf_ptr[i] & 0xff);
  }

  // status = _di();
  _di();
  ucx_queue_enqueue(pktdrv_queue, buf_ptr);
  _ei();

  return error;
}


/**
 * @brief Sends a message to a task (blocking send).
 *
 * @param target_cpu is the target processor
 * @param target_port is the target task port
 * @param buf is a pointer to a buffer that holds the message
 * @param size is the size (in bytes) of the message
 * @param channel is the selected message channel of this message (must be the same as in the receiver)
 *
 * @return ERR_OK
 *
 * A message is broken into packets containing a header and part of the message as the payload.
 * The packets are injected, one by one, in the network through the network interface.
 */
int32_t ucx_noc_send(uint16_t target_cpu, uint16_t target_port, int8_t *buf, uint16_t size, uint16_t channel)
{
#define NOC_PACKET_SIZE 64

  uint16_t packet = 0, packets, payload_bytes, id;
  int32_t i, p = 0;
  uint16_t out_buf[NOC_PACKET_SIZE];

  id = ucx_task_id();
  if (pktdrv_tqueue[id] == NULL)
    return ERR_COMM_UNFEASIBLE;

  payload_bytes = (NOC_PACKET_SIZE - PKT_HEADER_SIZE) * sizeof(uint16_t);
  packets = (size % payload_bytes == 0) ? (size / payload_bytes) : (size / payload_bytes + 1);

  while (++packet < packets)
  {
    out_buf[PKT_TARGET_CPU] = target_cpu;
    out_buf[PKT_PAYLOAD] = NOC_PACKET_SIZE - 2;
    out_buf[PKT_SOURCE_CPU] = id;
    out_buf[PKT_SOURCE_PORT] = pktdrv_ports[id];
    out_buf[PKT_TARGET_PORT] = target_port;
    out_buf[PKT_MSG_SIZE] = size;
    out_buf[PKT_SEQ] = packet;
    out_buf[PKT_CHANNEL] = channel;

    for (i = PKT_HEADER_SIZE; i < NOC_PACKET_SIZE; i++, p += 2)
      out_buf[i] = ((uint8_t)buf[p] << 8) | (uint8_t)buf[p + 1];

    // ni_write_packet(out_buf, NOC_PACKET_SIZE)
    while(_ddma_async_send(target_cpu, NOC_PACKET_SIZE, (uint32_t*)out_buf));
  }

  out_buf[PKT_TARGET_CPU] = ucx_noc_cpu_id();

  // Last packet, which most of the time is the only packet, must have size equals
  // to the number of flits in the payload plus two, instead of NOC_PACKET_SIZE.
  // COMMENTED OUT >> out_buf[PKT_PAYLOAD] = NOC_PACKET_SIZE - 2;
  out_buf[PKT_SOURCE_CPU] = ucx_task_id();
  out_buf[PKT_SOURCE_PORT] = pktdrv_ports[id];
  out_buf[PKT_TARGET_PORT] = target_port;
  out_buf[PKT_MSG_SIZE] = size;
  out_buf[PKT_SEQ] = packet;
  out_buf[PKT_CHANNEL] = channel;

  for (i = PKT_HEADER_SIZE; i < NOC_PACKET_SIZE && (p < size); i++, p += 2)
    out_buf[i] = ((uint8_t)buf[p] << 8) | (uint8_t)buf[p + 1];

  // Actual size of payload fixed here (total data minus the first two flits).
  out_buf[PKT_PAYLOAD] = i - 2;

  //ni_write_packet(out_buf, i);
  while(_ddma_async_send(target_cpu, i, (uint32_t*)out_buf));

  return ERR_OK;
}

/**
 * @brief Receives a message from a task (blocking receive) with acknowledgement.
 *
 * @param source_cpu is a pointer to a variable which will hold the source cpu
 * @param source_port is a pointer to a variable which will hold the source port
 * @param buf is a pointer to a buffer to hold the received message
 * @param size a pointer to a variable which will hold the size (in bytes) of the received message
 * @param channel is the selected message channel of this message (must be the same as in the sender)
 *
 * @return ERR_OK when successful, ERR_COMM_UNFEASIBLE when no message queue (comm) was
 * created and ERR_SEQ_ERROR when received packets arrive out of order, so the message
 * is corrupted.
 *
 * A message is build from packets received on the ni_isr() routine. Packets are decoded and
 * combined in a complete message, returning the message, its size and source identification
 * to the calling task. The buffer where the message will be stored must be large enough or
 * we will have a problem that may not be noticed before its too late. After the reception
 * of the whole message is completed, an acknowledgement is sent to the sender task. This works
 * as a flow control mechanism, avoiding buffer/queue overflows common to the raw protocol.
 * Message channel 32767 will be used for the flow control mechanism. This routine must be used
 * exclusively with ucx_noc_sendack().
 */
int32_t ucx_noc_recvack(uint16_t *source_cpu, uint16_t *source_port, int8_t *buf, uint16_t *size, uint16_t channel)
{
  int32_t error;

  error = ucx_noc_recv(source_cpu, source_port, buf, size, channel);
  if (error == ERR_OK)
  {
    ucx_noc_send(*source_cpu, *source_port, "ok", 3, 0x7fff);
  }

  return error;
}

/**
 * @brief Sends a message to a task (blocking send) with acknowledgement.
 *
 * @param target_cpu is the target processor
 * @param target_port is the target task port
 * @param buf is a pointer to a buffer that holds the message
 * @param size is the size (in bytes) of the message
 * @param channel is the selected message channel of this message (must be the same as in the receiver)
 * @param timeout is the time (in ms) that the sender will wait for a reception acknowledgement
 *
 * @return ERR_OK
 *
 * A message is broken into packets containing a header and part of the message as the payload.
 * The packets are injected, one by one, in the network through the network interface. After that, the
 * sender will wait for an acknowledgement from the receiver. This works as a flow control mechanism,
 * avoiding buffer/queue overflows common to the raw protocol. Message channel 32767 will be used for
 * the flow control mechanism. This routine should be used exclusively with ucx_noc_recvack().
 */
int32_t ucx_noc_sendack(uint16_t target_cpu, uint16_t target_port, int8_t *buf, uint16_t size, uint16_t channel, uint32_t timeout)
{
  uint16_t id, source_cpu, source_port;
  int32_t error, k;
  uint32_t time;
  int8_t ack[4];
  uint16_t *buf_ptr;

  error = ucx_noc_send(target_cpu, target_port, buf, size, channel);
  if (error == ERR_OK)
  {
    id = ucx_task_id();
    time = _read_us() / 1000;
    while (1)
    {
      k = ucx_queue_count(pktdrv_tqueue[id]);
      if (k)
      {
        buf_ptr = ucx_queue_peek(pktdrv_tqueue[id]);
        if (buf_ptr)
          if (buf_ptr[PKT_CHANNEL] == 0x7fff && buf_ptr[PKT_MSG_SIZE] == 3)
            break;
      }
      if (((_read_us() / 1000) - time) > timeout)
        return ERR_COMM_TIMEOUT;
    }
    ucx_noc_recv(&source_cpu, &source_port, ack, &size, 0x7fff);
  }

  return error;
}
