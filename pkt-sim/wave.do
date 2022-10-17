onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/clock}
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/reset}
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/tx}
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/credit_i}
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/data_o}
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/rx}
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/credit_o}
add wave -noupdate -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/data_i}
add wave -noupdate -expand -group router_port_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/tx}
add wave -noupdate -expand -group router_port_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/credit_i}
add wave -noupdate -expand -group router_port_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/data_o}
add wave -noupdate -expand -group router_port_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/rx}
add wave -noupdate -expand -group router_port_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/credit_o}
add wave -noupdate -expand -group router_port_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/data_i}
add wave -noupdate -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/tx}
add wave -noupdate -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/credit_i}
add wave -noupdate -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/data_o}
add wave -noupdate -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/rx}
add wave -noupdate -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/credit_o}
add wave -noupdate -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/data_i}
add wave -noupdate -expand -group mmio_if -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/addr_in}
add wave -noupdate -expand -group mmio_if -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/data_in}
add wave -noupdate -expand -group mmio_if {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/data_out}
add wave -noupdate -expand -group mmio_if {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/wb_in}
add wave -noupdate -expand -group mem_if_mmio {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/data_in}
add wave -noupdate -expand -group mem_if_mmio {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/addr_in}
add wave -noupdate -expand -group mem_if_mmio {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/data_out}
add wave -noupdate -expand -group mem_if_mmio {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/enable_in}
add wave -noupdate -expand -group mem_if_mmio {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/wb_in}
add wave -noupdate -expand -group mem_if_ddma {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -expand -group mem_if_ddma {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -expand -group mem_if_ddma {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -expand -group mem_if_ddma {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/enable_in}
add wave -noupdate -expand -group mem_if_ddma {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -color Cyan {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_token}
add wave -noupdate {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_state}
add wave -noupdate -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -expand -group ddma_if -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/addr_in}
add wave -noupdate -expand -group ddma_if -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/nbytes_in}
add wave -noupdate -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/cmd_in}
add wave -noupdate -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/status_out}
add wave -noupdate -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/irq_out}
add wave -noupdate -expand -group tcd_in {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/input_in}
add wave -noupdate -expand -group tcd_in -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/data_in}
add wave -noupdate -expand -group tcd_in {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/status_out}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3130 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 257
configure wave -valuecolwidth 112
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
WaveRestoreZoom {0 ps} {105 ns}
