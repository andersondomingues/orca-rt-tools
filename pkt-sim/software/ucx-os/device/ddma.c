#include <ucx.h>

volatile uint32_t* DDMA_NODE_ADDR = (uint32_t *)(0x20000000);
#define DDMA_NODE_DIMX ((* DDMA_NODE_ADDR & 0xFF000000) >> 24)
#define DDMA_NODE_DIMY ((* DDMA_NODE_ADDR & 0x00FF0000) >> 16)
#define DDMA_NODE_X ((* DDMA_NODE_ADDR & 0x0000FF00) >> 8)
#define DDMA_NODE_Y ((* DDMA_NODE_ADDR & 0x000000FF))

// DDMA send protocol
// DDMA_DEST_IN destination CPU (XY address)
// DDMA_PPTR_IN pointer to the packet to be sent
// DDMA_SIZE_IN number of flits to send 
// DDMA_CMD_IN  command to start the dma copy
volatile uint32_t* DDMA_DEST_IN = (uint32_t *)(0x20000004); 
volatile uint32_t* DDMA_ADDR_IN = (uint32_t *)(0x20000008);
volatile uint32_t* DDMA_SIZE_IN = (uint32_t *)(0x2000000C);
volatile uint32_t* DDMA_CMD_IN  = (uint32_t *)(0x20000010);


volatile uint32_t* DDMA_STATUS   = (uint32_t *)(0x20000014);
volatile uint32_t* DDMA_NPTR_OUT = (uint32_t *)(0x20000018); // next pointer
volatile uint32_t* DDMA_PPTR_OUT = (uint32_t *)(0x2000001C); // recvd pointer

uint32_t _ddma_node_addr(){
  return DDMA_NODE_Y * DDMA_NODE_DIMY + DDMA_NODE_X;
}

uint32_t _ddma_atox(uint32_t addr){
  return (addr % DDMA_NODE_DIMX);
}

uint32_t _ddma_atoy(uint32_t addr){
  return (addr / DDMA_NODE_DIMY);
}

uint32_t _ddma_xyta(uint32_t x, uint32_t y){
  return (x << 8) & y;
}

uint32_t _ddma_init(){
  printf("_ddma_init(): device info x:%d, y:%d, dimx:%d, dimy:%d\n", 
    DDMA_NODE_X, DDMA_NODE_Y, DDMA_NODE_DIMX, DDMA_NODE_DIMY);
  return 0;
}

uint32_t _ddma_async_send(uint32_t dest, uint32_t size, uint32_t* payload){
  *DDMA_DEST_IN = (_ddma_atox(dest) << 8) | _ddma_atoy(dest);
  
  // size is actually the number of flits to be sent, not 
  // the number of bytes.
  uint32_t data_size = (size % 4 == 0) ? (size / 4) : ((size / 4) + 1);

  printf("data_size: %d\n", data_size);

  * DDMA_SIZE_IN = data_size;
  * DDMA_ADDR_IN = (uint32_t) payload;
  * DDMA_CMD_IN  = 0x1; // starts dma copy
  return 0;
}

uint8_t _ddma_status(){
  printf("%h\n", *DDMA_STATUS);
  return *DDMA_STATUS;
}

uint32_t _ddma_conf_recv(uint32_t* addr){
  *DDMA_NPTR_OUT = (uint32_t)addr;
  return 0;
}

uint32_t* _ddma_recv_ptr_out(){
  return (uint32_t*)(*DDMA_ADDR_IN);
}