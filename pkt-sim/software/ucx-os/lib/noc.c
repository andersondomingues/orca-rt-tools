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


// Implementation of the irq1_handler, intercepts 
// sending interruptions. While sending, the ddma 
// will interrupt the cpu to acknowledge the sending
// right after all the flits were transmitted.
void irq1_handler(void){
  _ddma_async_ack(); // flag down the cmd_in variable.
}


// Implementation of the irq2_handler, intercepts 
// receiving interruptions. Once the ddma receives the 
// size flit, it interrupts the cpu to acquire a pointer
// to the heap of the length of the packet. 
void irq2_handler(void){
  uint32_t pkt_size = _ddma_recv_size(); // packet size in flits
  printf("irq2_handler(): incoming packet of size %d (flits)\n", pkt_size);
  
  noc_packet_t* pkt = (noc_packet_t*) ucx_malloc(pkt_size * 4); // malloc in bytes
  printf("irq2_handler(): ucx_malloc returned 0x%x\n", (uint32_t)pkt);

  _ddma_set_recv_addr((uint32_t)pkt); // send packet address to the ddma
  _ddma_recv_ack();
}

// Implementation of the irq3_handler, intercepts
// receiving interruptions. Once all flits were received, 
// interrupts the cpu to put the packet int the 
// right queue accordingly to its port.
void irq3_handler(void){

  noc_packet_t* pkt = (noc_packet_t*) _ddma_get_recv_addr();

  printf("irq3_handler(): received packet stored at 0x%x\n", pkt);

  printf("irq3_handler() 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n",
    (pkt->source_node), (pkt->target_node),
    (pkt->source_port), (pkt->target_port),
    (pkt->payload_size), (pkt->tag)
  );

  printf("irq3_handler() %c%c%c%c %c%c%c%c\n",
    pkt->data[0], pkt->data[1],
    pkt->data[2], pkt->data[3],
    pkt->data[4], pkt->data[5],
    pkt->data[6], pkt->data[7]
  );

  // get rid of packets which address is not the same of this cpu
  if (pkt->target_node != ucx_noc_cpu_id())
  {
    printf("noc_driver_isr(): wrong destination %x (expected %x).\n",
      pkt->target_node, ucx_noc_cpu_id());
    printf("noc_driver_isr(): packet at %x dropped.\n", pkt);
    ucx_free(pkt);
  } else {

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
  _ddma_recv_ack();
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

// initializes the driver
void noc_driver_init(void)
{
  // init hardware
  _ddma_init();

  // print out node id (from MMIO)
  printf("noc_driver_init(): this is core #%d\n", ucx_noc_cpu_id());
  
  // allocate a new queue of packets
  pktdrv_queue = ucx_queue_create(MAX_PKT_QUEUE_SLOTS);
  
  if (pktdrv_queue == NULL){
    printf("noc_driver_init(): unable to create packet queue\n");
  } else {

    // make sure no port is allocated at time zero 
    for (int32_t i = 0; i < MAX_TASKS; i++) 
      pktdrv_ports[i] = 0;
    
    // print out the address of handlers
    printf("noc_driver_init(): noc driver send irq handler at 0x%0x\n", &irq1_handler);
    printf("noc_driver_init(): noc driver recv irq handler at 0x%0x\n", &irq2_handler);
  }

  // enable irq pins 1 (sending) and 2 (receiving)
  IRQ_MASK |= MASK_IRQ1 | MASK_IRQ2 | MASK_IRQ3;
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
  size = (size % 4 == 0) ? size : ((size + 1) / 4) * 4;
  
  noc_packet_t* pkt = (noc_packet_t*) ucx_malloc(sizeof(noc_packet_t) + size);

  if(pkt){
    pkt->payload_size = size;
    pkt->source_node = ucx_noc_cpu_id();
    pkt->source_port = pktdrv_ports[ucx_task_id()];

    ucx_memset(pkt->data, 0, size);
    
  } else {
    printf("ucx_noc_create_packet(): unable to malloc\n");
  }

  return pkt;
};

/**
 * @brief Sends a message to a task (blocking send).
 *
 * @param target_cpu is the target processor
 * @param target_port is the target task port
 * @param pkt is a pointer to a packet 
 * @param tag user-defined tag
 *
 * @return ERR_OK
 *
 * A message is broken into packets containing a header and part of the message as the payload.
 * The packets are injected, one by one, in the network through the network interface.
 */
uint32_t ucx_noc_send(uint16_t target_cpu, uint16_t target_port, 
  noc_packet_t* pkt, uint16_t tag)
{
  //check whether the packet destination lies in the same pcore
  if(target_cpu != ucx_noc_cpu_id()) {
    // prevent user from sending another packet until the 
    // ddma gets ready again (0x1 is the idle state)
    while(_ddma_send_status() != 0x1);

    pkt->target_node = target_cpu;
    pkt->target_port = target_port;
    pkt->tag = tag;

    printf("ucx_noc_send() 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x %s\n",
      pkt->source_node, pkt->target_node,
      pkt->source_port, pkt->target_port,
      pkt->payload_size, pkt->tag,
      pkt->data
    );

    // send async
    return _ddma_async_send(target_cpu, sizeof(noc_packet_t) + pkt->payload_size,
      (uint32_t*)pkt);
  } else {
    printf("ucx_noc_send(): packet with same source/destination\n");
    return -1;
  }
}
