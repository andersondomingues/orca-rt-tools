onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ddma_noc_top/clock
add wave -noupdate /ddma_noc_top/reset
add wave -noupdate -group 00_ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/addr_in}
add wave -noupdate -group 00_ddma_if -radix decimal {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/nbytes_in}
add wave -noupdate -group 00_ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/cmd_in}
add wave -noupdate -group 00_ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/status_out}
add wave -noupdate -group 00_ddma_state -radix decimal {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -group 00_ddma_state -radix hexadecimal {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -group 00_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -group 00_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/i_token}
add wave -noupdate -group 00_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/sstate}
add wave -noupdate -group 00_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_mod/rstate}
add wave -noupdate -group 00_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/MEMORY_BUS_WIDTH}
add wave -noupdate -group 00_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group 00_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group 00_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group 00_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/enable_in}
add wave -noupdate -group 00_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -group router_00 -color Magenta {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -group router_00 {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -group router_00 -childformat {{{/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -subitemconfig {{/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} {-height 17 -radix hexadecimal}} {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -group router_00 {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -group router_00 {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -group router_00 {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -group router_00 {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/credit_i}
add wave -noupdate -group 10_ddma_if {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/addr_in}
add wave -noupdate -group 10_ddma_if -radix decimal {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/nbytes_in}
add wave -noupdate -group 10_ddma_if {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/cmd_in}
add wave -noupdate -group 10_ddma_if {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/status_out}
add wave -noupdate -group 10_ddma_state -radix decimal {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -group 10_ddma_state -radix hexadecimal {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -group 10_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -group 10_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/i_token}
add wave -noupdate -group 10_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/sstate}
add wave -noupdate -group 10_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/ddma_mod/rstate}
add wave -noupdate -group 10_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/MEMORY_BUS_WIDTH}
add wave -noupdate -group 10_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group 10_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group 10_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group 10_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/enable_in}
add wave -noupdate -group 10_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -group router_10 -color Magenta {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -group router_10 {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -group router_10 -childformat {{{/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -subitemconfig {{/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} {-height 17 -radix hexadecimal}} {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -group router_10 {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -group router_10 {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -group router_10 {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -group router_10 {/ddma_noc_top/pe_x[1]/pe_y[0]/pe_mod/router_mod/router_mod/credit_i}
add wave -noupdate -group 01_ddma_if {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/addr_in}
add wave -noupdate -group 01_ddma_if -radix decimal {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/nbytes_in}
add wave -noupdate -group 01_ddma_if {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/cmd_in}
add wave -noupdate -group 01_ddma_if {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/status_out}
add wave -noupdate -group 01_ddma_state -radix decimal {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -group 01_ddma_state -radix hexadecimal {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -group 01_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -group 01_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/i_token}
add wave -noupdate -group 01_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/sstate}
add wave -noupdate -group 01_ddma_state {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/ddma_mod/rstate}
add wave -noupdate -group 01_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/mem_if_dma/MEMORY_BUS_WIDTH}
add wave -noupdate -group 01_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group 01_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group 01_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group 01_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/mem_if_dma/enable_in}
add wave -noupdate -group 01_mem_ddma {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -group router_01 -color Magenta {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -group router_01 {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -group router_01 -childformat {{{/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -subitemconfig {{/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} {-height 17 -radix hexadecimal}} {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -group router_01 {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -group router_01 {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -group router_01 {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -group router_01 {/ddma_noc_top/pe_x[0]/pe_y[1]/pe_mod/router_mod/router_mod/credit_i}
add wave -noupdate -group 11_ddma_if {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/addr_in}
add wave -noupdate -group 11_ddma_if -radix decimal {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/nbytes_in}
add wave -noupdate -group 11_ddma_if {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/cmd_in}
add wave -noupdate -group 11_ddma_if {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_tb_mod/ddma_if/status_out}
add wave -noupdate -group 11_ddma_state -radix decimal {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/temp_addr_in}
add wave -noupdate -group 11_ddma_state -radix hexadecimal {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/temp_num_flits_in}
add wave -noupdate -group 11_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/i_flip_counter}
add wave -noupdate -group 11_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/i_token}
add wave -noupdate -group 11_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/sstate}
add wave -noupdate -group 11_ddma_state {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/ddma_mod/rstate}
add wave -noupdate -group 11_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/MEMORY_BUS_WIDTH}
add wave -noupdate -group 11_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/data_in}
add wave -noupdate -group 11_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/addr_in}
add wave -noupdate -group 11_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/data_out}
add wave -noupdate -group 11_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/enable_in}
add wave -noupdate -group 11_mem_ddma {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/mem_if_dma/wb_in}
add wave -noupdate -group router_11 -color Magenta {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/SwitchControl/ES}
add wave -noupdate -group router_11 {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/rx}
add wave -noupdate -group router_11 -childformat {{{/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/data_in(4)} -radix hexadecimal}} -subitemconfig {{/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/router_mod/router_mod/data_in(4)} {-height 17 -radix hexadecimal}} {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/data_in}
add wave -noupdate -group router_11 {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/credit_o}
add wave -noupdate -group router_11 {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/tx}
add wave -noupdate -group router_11 {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/data_out}
add wave -noupdate -group router_11 {/ddma_noc_top/pe_x[1]/pe_y[1]/pe_mod/router_mod/router_mod/credit_i}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{End Test 1} {1237119267 ps} 0 Cyan Cyan} {Trace {2308654954 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 257
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
WaveRestoreZoom {1189093392 ps} {1256113423 ps}