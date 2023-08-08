onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /manycore_top/clock
add wave -noupdate /manycore_top/reset
add wave -noupdate -divider {Node 0-0}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/clock}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/reset}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/addr_in}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/data_in}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/data_out}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/sel_in}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/wr_in}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/irq}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/gpioa_in}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/gpioa_out}
add wave -noupdate -group 00_perif {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/perif_if/gpioa_ddr}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/clock}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/reset}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/send_addr_in}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/send_size_in}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/send_dest_in}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/send_cmd_in}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/recv_addr_in}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/recv_addr_out}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/recv_size_out}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/recv_cmd_in}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/irq_send_out}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/irq_recv_size_out}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/irq_recv_hshk_out}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/state_recv_out}
add wave -noupdate -group 00_ddma_if {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_if/state_send_out}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/MEMORY_BUS_WIDTH}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/FLIT_WIDTH}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/INTERLEAVING_GRAIN}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/ADDRESS}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/clock}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/reset}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/istate}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/sstate}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/rstate}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_destination}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_flits_to_recv}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_recv_addr}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/has_data_to_send}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/has_data_to_recv}
add wave -noupdate -expand -group 00_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/old_recv_cmd_in}
add wave -noupdate -group 00_mem_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/MEMORY_BUS_WIDTH}
add wave -noupdate -group 00_mem_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group 00_mem_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group 00_mem_ddma -color Orange {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group 00_mem_ddma {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -group 00_mmio_if {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_mmio/data_in}
add wave -noupdate -group 00_mmio_if {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_mmio/addr_in}
add wave -noupdate -group 00_mmio_if {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_mmio/data_out}
add wave -noupdate -group 00_mmio_if -expand {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_mmio/wb_in}
add wave -noupdate -expand -group 00_router -color Magenta {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -expand -group 00_router {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/FLocal/EA}
add wave -noupdate -expand -group 00_router {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/FLocal/counter_flit}
add wave -noupdate -expand -group 00_router -expand -subitemconfig {{/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/rx(4)} {-color Gold -height 16}} {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -expand -group 00_router -childformat {{{/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -expand -subitemconfig {{/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} {-color Gold -height 17 -radix hexadecimal}} {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -expand -group 00_router -expand {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -expand -group 00_router {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -expand -group 00_router {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -expand -group 00_router {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/credit_i}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/stall_i}
add wave -noupdate -group 00_cpu -color Magenta {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/addr_o}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_i}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_o}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_w_o}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_mode_o}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/extio_in}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/extio_out}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/stall_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/mwait_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/irq_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/irq_ack_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/exception_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_b_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_h_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_access_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/irq_vector_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/inst_addr_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/inst_in_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_addr_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_in_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_out_cpu}
add wave -noupdate -group 00_cpu {/manycore_top/pe_x[0]/pe_y[0]/pe_mod/cpu_mod/processor/data_w_cpu}
add wave -noupdate -divider {Node 1-0}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/clock}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/reset}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/addr_in}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/data_in}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/data_out}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/sel_in}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/wr_in}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/irq}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/gpioa_in}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/gpioa_out}
add wave -noupdate -group 10_perif {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/perif_if/gpioa_ddr}
add wave -noupdate -group 10_ddma_state -radix decimal {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -group 10_ddma_state -radix hexadecimal {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -group 10_ddma_state {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -group 10_ddma_state {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/sstate}
add wave -noupdate -group 10_ddma_state {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/rstate}
add wave -noupdate -group 10_mem_ddma {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/MEMORY_BUS_WIDTH}
add wave -noupdate -group 10_mem_ddma {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group 10_mem_ddma {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group 10_mem_ddma {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group 10_mem_ddma {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -group 10_router -color Magenta {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -group 10_router {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/FLocal/EA}
add wave -noupdate -group 10_router {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/FLocal/counter_flit}
add wave -noupdate -group 10_router {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -group 10_router -childformat {{{/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -subitemconfig {{/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} {-height 17 -radix hexadecimal}} {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -group 10_router {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -group 10_router {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -group 10_router {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -group 10_router {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/credit_i}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/stall_i}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/addr_o}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_i}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_o}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_w_o}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_mode_o}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/extio_in}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/extio_out}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/stall_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/mwait_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/irq_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/irq_ack_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/exception_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_b_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_h_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_access_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/irq_vector_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/inst_addr_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/inst_in_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_addr_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_in_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_out_cpu}
add wave -noupdate -group 10_cpu {/manycore_top/pe_x[1]/pe_y[0]/pe_mod/cpu_mod/processor/data_w_cpu}
add wave -noupdate -divider {Node 0-1}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/clock}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/reset}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/addr_in}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/data_in}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/data_out}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/sel_in}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/wr_in}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/irq}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/gpioa_in}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/gpioa_out}
add wave -noupdate -group 01_perif {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/perif_if/gpioa_ddr}
add wave -noupdate -expand -group 01_router {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -expand -group 01_router {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/FLocal/EA}
add wave -noupdate -expand -group 01_router {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/FLocal/counter_flit}
add wave -noupdate -expand -group 01_router -expand {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -expand -group 01_router -childformat {{{/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -subitemconfig {{/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_in(4)} {-height 17 -radix hexadecimal}} {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -expand -group 01_router {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -expand -group 01_router -expand {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -expand -group 01_router -expand -subitemconfig {{/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_out(4)} {-color Gold -height 16}} {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -expand -group 01_router -expand -subitemconfig {{/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/credit_i(4)} {-color Gold -height 16}} {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/credit_i}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/stall_i}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/addr_o}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_i}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_o}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_w_o}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_mode_o}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/extio_in}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/extio_out}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/stall_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/mwait_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/irq_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/irq_ack_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/exception_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_b_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_h_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_access_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/irq_vector_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/inst_addr_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/inst_in_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_addr_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_in_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_out_cpu}
add wave -noupdate -group 01_cpu {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/cpu_mod/processor/data_w_cpu}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/MEMORY_BUS_WIDTH}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/FLIT_WIDTH}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/INTERLEAVING_GRAIN}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/ADDRESS}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/RAM_MSIZE}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/clock}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/reset}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/istate}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/sstate}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/rstate}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/temp_destination}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/temp_flits_to_recv}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/temp_recv_addr}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/has_data_to_send}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/has_data_to_recv}
add wave -noupdate -expand -group 01_ddma {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/old_recv_cmd_in}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/MEMORY_BUS_WIDTH}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/FLIT_WIDTH}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/INTERLEAVING_GRAIN}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/ADDRESS}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/clock}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/reset}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/send_addr_in}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/send_size_in}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/send_dest_in}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/send_cmd_in}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/recv_addr_in}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/recv_addr_out}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/recv_size_out}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/recv_cmd_in}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/irq_send_out}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/irq_recv_size_out}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/irq_recv_hshk_out}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/state_recv_out}
add wave -noupdate -expand -group 01_ddma_if {/manycore_top/pe_x[0]/pe_y[1]/pe_mod/ddma_if/state_send_out}
add wave -noupdate -divider {Node 1-1}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/clock}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/reset}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/addr_in}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/data_in}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/data_out}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/sel_in}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/wr_in}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/irq}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/gpioa_in}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/gpioa_out}
add wave -noupdate -group 11_perif {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/perif_if/gpioa_ddr}
add wave -noupdate -group 11_ddma_state -radix decimal {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -group 11_ddma_state -radix hexadecimal {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -group 11_ddma_state {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -group 11_ddma_state {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/sstate}
add wave -noupdate -group 11_ddma_state {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/rstate}
add wave -noupdate -group 11_mem_ddma {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/MEMORY_BUS_WIDTH}
add wave -noupdate -group 11_mem_ddma {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group 11_mem_ddma {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group 11_mem_ddma {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group 11_mem_ddma {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -group 11_router -color Magenta {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -group 11_router {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/FLocal/EA}
add wave -noupdate -group 11_router {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/FLocal/counter_flit}
add wave -noupdate -group 11_router {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -group 11_router -childformat {{{/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -subitemconfig {{/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/data_in(4)} {-height 17 -radix hexadecimal}} {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -group 11_router {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -group 11_router {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -group 11_router {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -group 11_router {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/credit_i}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/stall_i}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/addr_o}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_i}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_o}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_w_o}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_mode_o}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/extio_in}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/extio_out}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/stall_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/mwait_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/irq_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/irq_ack_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/exception_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_b_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_h_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_access_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/irq_vector_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/inst_addr_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/inst_in_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_addr_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_in_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_out_cpu}
add wave -noupdate -group 11_cpu {/manycore_top/pe_x[1]/pe_y[1]/pe_mod/cpu_mod/processor/data_w_cpu}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {pkt {77007998 ps} 1} {{Cursor 2} {144215221 ps} 1} {{Cursor 3} {110581130 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 304
configure wave -valuecolwidth 111
configure wave -justifyvalue left
configure wave -signalnamewidth 3
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {110560525 ps} {110590567 ps}
