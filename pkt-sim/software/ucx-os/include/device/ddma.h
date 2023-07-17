// returns the identifier of this node (node number),
// which is unique per pe. XY identifiers are 
// available through memory-mapped I/O, and address
// identifier is done through software conversion.
uint32_t _ddma_node_addr();

// initialize ddma registers and print test routine output
uint32_t _ddma_init();

// copies a packet from the memory into the network. copy 
// is performed in a dma fashion
uint32_t _ddma_async_send(uint32_t dest, uint32_t size, uint32_t* payload);

// recv
uint32_t* _ddma_recv_ptr_out();

// 8-bit register
// ---------------------------------
// | s | r | S | S | S | R | R | R |
// ---------------------------------
//   0   1   2   3   4   5   6   7

// [4:2] send state machine status 
// [7:5] recv state machine status 
// [0]   send proc. irq
// [1]   recv. proc. irq

// send process state machine states codes
// WAIT_CONFIG = 0
// SENDING_HEADER = 1
// SENDING_SIZE = 2
// SENDING_PAYLOAD = 3
// HANDSHAKE = 4

// recv process state machine states 
// IDLE_REC = 0,
// REC_HEADER = 1,
// REC_SIZE = 2,
// REC_PAYLOAD = 3,
// IRQ_REC = 4,
// REC_HEADER_SYNC = 5
uint8_t _ddma_status();

uint32_t _ddma_send_status();

// flag down sending and reset the state machine, allowing
// for a new sending configuration
void _ddma_async_ack();

#define DDMA_SEND_ACTIVE 0xC0
#define DDMA_RECV_ACTIVE 0x30
