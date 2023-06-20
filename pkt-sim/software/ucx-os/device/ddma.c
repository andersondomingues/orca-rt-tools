#include <ucx.h>

volatile uint32_t* DDMA_NODE_ADDR = (uint32_t *)(0x20000000);
#define DDMA_NODE_DIMX ((* DDMA_NODE_ADDR & 0xFF000000) >> 24)
#define DDMA_NODE_DIMY ((* DDMA_NODE_ADDR & 0x00FF0000) >> 16)
#define DDMA_NODE_X ((* DDMA_NODE_ADDR & 0x0000FF00) >> 8)
#define DDMA_NODE_Y ((* DDMA_NODE_ADDR & 0x000000FF))

volatile uint32_t * DDMA_DEST_IN = (uint32_t *)(0x20000004);
volatile uint32_t * DDMA_PPTR_IN = (uint32_t *)(0x20000008);
volatile uint32_t * DDMA_SIZE_IN = (uint32_t *)(0x2000000A);

volatile uint32_t * DDMA_STATUS   = (uint32_t *)(0x20000010);
volatile uint32_t * DDMA_NPTR_OUT = (uint32_t *)(0x20000008); // next pointer
volatile uint32_t * DDMA_PPTR_OUT = (uint32_t *)(0x20000008); // recvd pointer

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
  *DDMA_SIZE_IN = size;
  *DDMA_PPTR_IN = (uint32_t)payload;
  return 0;
}

uint32_t _ddma_status(){
  return *DDMA_STATUS;
}

uint32_t _ddma_conf_recv(uint32_t* addr){
  *DDMA_NPTR_OUT = (uint32_t)addr;
  return 0;
}

uint32_t* _ddma_recv_ptr_out(){
  return (uint32_t*)(*DDMA_PPTR_IN);
}