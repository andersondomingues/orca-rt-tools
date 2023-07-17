#include <ucx.h>


// binds tasks to ports
uint16_t pktdrv_ports[MAX_TASKS];

// queues of packets for each task
struct queue_s *pktdrv_tqueue[MAX_TASKS];

// queue of shared packets 
struct queue_s *pktdrv_queue;

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
    return UCX_NOC_TASK_BIND_ALREADY;

  // port already in use by another task
  for (int k = 0; k < MAX_TASKS; k++)
    if (pktdrv_ports[k] == port)
      return UCX_NOC_PORT_BIND_ALREADY;

  // add a new queue to receive packets for that task
  pktdrv_tqueue[task_id] = ucx_queue_create(MAX_PKT_QUEUE_SLOTS);

  // if we cannot create a new queue due to unavailable memory
  // space, return ERR_OUT_OF_MEMORY
  if (pktdrv_tqueue[task_id] == 0)
    return UCX_NOC_OUT_OF_MEMORY;

  // connect the port to the task and return ERR_OK
  pktdrv_ports[task_id] = port;
  return UCX_NOC_OK;
}

// Destroys a connection, removing the
uint32_t ucx_noc_comm_destroy(uint16_t port)
{
  int task_id = ucx_task_id();

  _di();

  // removes all elements from the comm queue, adding them
  // to the queue of shared packets
  while (ucx_queue_count(pktdrv_tqueue[task_id]))
    ucx_queue_enqueue(pktdrv_queue, ucx_queue_dequeue(pktdrv_tqueue[task_id]));

  _ei();

  // check whether the comm queue was gracefully destroyed. If not,
  // return ERR_COMM_ERROR
  if (ucx_queue_destroy(pktdrv_tqueue[task_id]))
    return UCX_NOC_UNABLE_TO_DESTROY;

  pktdrv_ports[task_id] = 0;
  return UCX_NOC_OK;
}

// Initializes the driver
void noc_driver_init(void)
{
  _ddma_init();

  printf("noc_driver_init(): this is core #%d\n", ucx_noc_cpu_id());
  printf("noc_driver_init(): noc queue init, %d packets\n", MAX_PKT_QUEUE_SLOTS);
  
  pktdrv_queue = ucx_queue_create(MAX_PKT_QUEUE_SLOTS);
  
  if (pktdrv_queue == NULL){
    printf("noc_driver_init(): unable to create packet queue\n");
    printf("noc_driver_init(): noc driver irq won't be registered\n");
  } else {
    for (int32_t i = 0; i < MAX_TASKS; i++){
      pktdrv_ports[i] = 0;
    }
    printf("noc_driver_init(): noc driver send isr registered 0x%0x\n", &irq1_handler);
    printf("noc_driver_init(): noc driver recv isr registered 0x%0x\n", &irq2_handler);
  }

  // enable irq pins 1 (sending) and 2 (receiving)
  IRQ_MASK |= MASK_IRQ1 | MASK_IRQ2;
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

void noc_driver_recv_isr()
{
  // Since we know the size of the received packet, we ask the driver to copy only
  // the necessary bytes. The size of the packet is written by the NI to the
  // sig_recv_status signal (see drv). We need to know the size of the packet before
  // receiving it, so it can be flushed case no more room is available
  printf("noc_driver_recv_isr\n");
  
  noc_packet_t* pkt  = (noc_packet_t*) _ddma_recv_ptr_out();


  // get rid of packets which address is not the same of this cpu
  if (pkt->target_node != ucx_noc_cpu_id())
  {
    printf("noc_driver_isr(): packet should not arrive at this node, target was %d", 
      pkt->target_node);

    // return pointer to the queue
    ucx_queue_enqueue(pktdrv_queue, pkt);
    return;
  }

  // get the queue associated to the port indicated in the packet
  int k;
  for (k = 0; k < MAX_TASKS; k++)
    if (pktdrv_ports[k] == pkt->target_port)
      break;

  // check whether the task has room for more packets in that queue
  if (ucx_queue_enqueue(pktdrv_tqueue[k], pkt))
  {
    printf("noc_driver_isr(): task (on port %d) cannot receive more packets, dropping", 
      pkt->target_port);
    ucx_queue_enqueue(pktdrv_queue, pkt);
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
  uint16_t task_id;
  int32_t k;
  noc_packet_t *buf_ptr;

  task_id = ucx_task_id();
  if (pktdrv_tqueue[task_id] == NULL)
    return UCX_NOC_TASK_NOT_BOUND;

  k = ucx_queue_count(pktdrv_tqueue[task_id]);
  if (k)
  {
    buf_ptr = (noc_packet_t*) ucx_queue_peek(pktdrv_tqueue[task_id]);
    if (buf_ptr)
      return buf_ptr->tag;
  }

  return UCX_NOC_QUEUE_EMPTY;
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
noc_packet_t* ucx_noc_recv(uint16_t channel)
{
  return ucx_queue_dequeue(pktdrv_tqueue[ucx_task_id()]);
}

/**
 * Request a new persistent data container from the heap to store a new 
 * package. The container has increased size as we need append the header
 * to it. This contrainer must be freed by the user.
 * 
 * @size number of bytes for the payload
*/
noc_packet_t* ucx_noc_create_packet(uint32_t size){
  // malloc once by allocating enough space for the 
  // packet structure and its data
  noc_packet_t* pkt = (noc_packet_t*) ucx_malloc(sizeof(noc_packet_t) + size);
  pkt->payload_size = size;
  pkt->source_node = ucx_noc_cpu_id();
  pkt->source_port = pktdrv_ports[ucx_task_id()];

  return pkt;
};

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
uint32_t ucx_noc_send(uint16_t target_cpu, uint16_t target_port, noc_packet_t* pkt, uint16_t tag)
{
  pkt->target_node = target_cpu;
  pkt->target_port = target_port;
  pkt->tag = tag;

  // hold until previous send op finishes
  while(_ddma_send_status());

  printf("ucx_noc_send() 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x %s\n",
    pkt->source_node, pkt->target_node,
    pkt->source_port, pkt->target_port,
    pkt->payload_size, pkt->tag,
    pkt->data
  );

  // send async
  return _ddma_async_send(target_cpu, sizeof(noc_packet_t) + pkt->payload_size, (uint32_t*)pkt);
}


// forwards isr to driver routine 
void irq1_handler(void){
  printf("noc_drive_send_ack_isr called\n");
  _ddma_async_ack();
};

// forwards isr to driver routine 
void irq2_handler(void){
  printf("noc_drive_recv_isr called\n");
  noc_driver_recv_isr();
};