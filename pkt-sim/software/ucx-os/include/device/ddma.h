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

