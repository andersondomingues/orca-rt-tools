`timescale 1 ns / 1 ps
`define NI_WORD_LENGTH 31

typedef enum logic[0:2] {
    CONFIG_WAIT = 0, // wait configuration from the network
    CONFIG_PUSH = 1, // push received configuration into the queue
    CONFIG_DONE = 2, // set queue pointers and leave configuration mode
    DMA_WAIT  = 3,   // wait until next packet release
    DMA_BURST = 4,   // burst packet data into the network 
    DMA_FLUSH = 5    // pop-push current configuration and wait
} tcni_state;

typedef bit[NI_WORD_LENGTH:0] word;

/**
    Time-Controlled Network Interface (TCNI)
    @brief: This module is the combination of DMA (direct memory access)
            module and a NI (network interface). The configuration of the 
            module is performed at the startup. Once configured, the module 
            is able to act as a DMA and move data from the memory to the 
            network. Different from usual NIs, the TCNI does not need the 
            processor core to activate the copy as the configuration states
            the period of copies. 
*/
module tcni (
    input bit clock,
    input bit reset,
    
    
    output word data_out,
    output
)

