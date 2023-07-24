#include <ucx.h>

void sender(void)
{
  printf("[task %d] started\n", ucx_task_id());

  // register port 500
  ucx_noc_comm_create(500);

  char* data = "ABCDEF";

  // gets a new packet from the system
  noc_packet_t* pkt = ucx_noc_create_packet(8);
  
  // copy contents into packet payload
  ucx_memcpy(pkt->data, data, 6);
  
            // dest size pkt tag
  ucx_noc_send(2, 800, pkt, 16);
  ucx_noc_send(2, 800, pkt, 16);
  ucx_noc_send(2, 800, pkt, 16);
  ucx_noc_send(2, 800, pkt, 16);
  //ucx_noc_send(2, 800, pkt, 16);
  //ucx_noc_send(2, 800, pkt, 16);
  // ucx_free(pkt);
  while(1);
}


void receiver(void)
{
  printf("[task %d] started\n", ucx_task_id());

  ucx_noc_comm_create(ucx_task_id());
  while(ucx_noc_recvprobe());
}


int32_t app_main(void)
{
  if (ucx_noc_cpu_id() == 0) {
    ucx_task_add(sender, DEFAULT_STACK_SIZE);
  } else {
    ucx_task_add(receiver, DEFAULT_STACK_SIZE);
  }
	

	return 1;
}
