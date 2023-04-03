onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/reset}
add wave -noupdate {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/clock}
add wave -noupdate -group {Router IF (all)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/tx}
add wave -noupdate -group {Router IF (all)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/credit_i}
add wave -noupdate -group {Router IF (all)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/data_o}
add wave -noupdate -group {Router IF (all)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/rx}
add wave -noupdate -group {Router IF (all)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/credit_o}
add wave -noupdate -group {Router IF (all)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/data_i}
add wave -noupdate -expand -group {Router Port (single)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/tx}
add wave -noupdate -expand -group {Router Port (single)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/credit_i}
add wave -noupdate -expand -group {Router Port (single)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/data_o}
add wave -noupdate -expand -group {Router Port (single)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/rx}
add wave -noupdate -expand -group {Router Port (single)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/credit_o}
add wave -noupdate -expand -group {Router Port (single)} {/tb/pe_x[0]/pe_y[0]/pe_mod/router_port_if/data_i}
add wave -noupdate -group {PE IF (NSWE)} {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/tx}
add wave -noupdate -group {PE IF (NSWE)} {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/credit_i}
add wave -noupdate -group {PE IF (NSWE)} {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/data_o}
add wave -noupdate -group {PE IF (NSWE)} {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/rx}
add wave -noupdate -group {PE IF (NSWE)} {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/credit_o}
add wave -noupdate -group {PE IF (NSWE)} {/tb/pe_x[0]/pe_y[0]/pe_mod/pe_if/data_i}
add wave -noupdate -expand -group {MMIO IF} {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/addr_in}
add wave -noupdate -expand -group {MMIO IF} {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/data_in}
add wave -noupdate -expand -group {MMIO IF} {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/data_out}
add wave -noupdate -expand -group {MMIO IF} {/tb/pe_x[0]/pe_y[0]/pe_mod/mmio_if/wb_in}
add wave -noupdate -group {MEM IF (mmio)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/data_in}
add wave -noupdate -group {MEM IF (mmio)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/addr_in}
add wave -noupdate -group {MEM IF (mmio)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/data_out}
add wave -noupdate -group {MEM IF (mmio)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/enable_in}
add wave -noupdate -group {MEM IF (mmio)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_mmio/wb_in}
add wave -noupdate -group {MEM IF (Dma)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group {MEM IF (Dma)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group {MEM IF (Dma)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group {MEM IF (Dma)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/enable_in}
add wave -noupdate -group {MEM IF (Dma)} {/tb/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -expand -group {DMA IF } -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/addr_in}
add wave -noupdate -expand -group {DMA IF } -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/nbytes_in}
add wave -noupdate -expand -group {DMA IF } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/cmd_in}
add wave -noupdate -expand -group {DMA IF } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/status_out}
add wave -noupdate -expand -group {DMA IF } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/irq_out}
add wave -noupdate -expand -group {ddma MOD } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/irq}
add wave -noupdate -expand -group {ddma MOD } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/has_data_to_send}
add wave -noupdate -expand -group {ddma MOD } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/has_data_to_recv}
add wave -noupdate -expand -group {ddma MOD } -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/memory_pointer_recv}
add wave -noupdate -expand -group {ddma MOD } -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/memory_pointer_send}
add wave -noupdate -expand -group {ddma MOD } -color Cyan -itemcolor Blue {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_token}
add wave -noupdate -expand -group {ddma MOD } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -expand -group {ddma MOD } {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/sstate}
add wave -noupdate -expand -group {ddma MOD } -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -expand -group {ddma MOD } -radix decimal {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_nbytes_in}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64946 ps} 0}
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
