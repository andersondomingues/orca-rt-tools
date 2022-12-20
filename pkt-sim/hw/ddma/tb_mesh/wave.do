onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/clock}
add wave -noupdate -expand -group ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/reset}
add wave -noupdate -expand -group ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/addr_in}
add wave -noupdate -expand -group ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/nbytes_in}
add wave -noupdate -expand -group ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/cmd_in}
add wave -noupdate -expand -group ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/status_out}
add wave -noupdate -expand -group ddma_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/ddma_if/irq_out}
add wave -noupdate -expand -group mem_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/mem_if/clock}
add wave -noupdate -expand -group mem_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/mem_if/reset}
add wave -noupdate -expand -group mem_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/mem_if/data_in}
add wave -noupdate -expand -group mem_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/mem_if/addr_in}
add wave -noupdate -expand -group mem_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/mem_if/data_out}
add wave -noupdate -expand -group mem_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/mem_if/enable_in}
add wave -noupdate -expand -group mem_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/mem_if/wb_in}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/clock}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/reset}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/clock_tx}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/tx}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/credit_i}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/data_o}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/clock_rx}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/rx}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/credit_o}
add wave -noupdate -expand -group router_if {/ddma_noc_top/pe_x[0]/pe_y[0]/pe_mod/ddma_tb_mod/router_if/data_i}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{End Test 1} {34821 ps} 1 Cyan Cyan} {{End Test 2} {109059 ps} 1 Cyan Cyan} {{End Test 3} {150433 ps} 1 default Cyan} {{Cursor 4} {131849 ps} 0}
quietly wave cursor active 4
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
WaveRestoreZoom {0 ps} {97201 ps}
