onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/clock}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/reset}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/clock_tx}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/tx}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/credit_i}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/data_o}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/clock_rx}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/rx}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/credit_o}
add wave -noupdate -height 19 -expand -group pe_if {/tb/pe_x[0]/pe_y[0]/pe_if/data_i}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/clock}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/reset}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/clock_tx}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/tx}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/credit_i}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/data_o}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/clock_rx}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/rx}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/credit_o}
add wave -noupdate -height 19 -expand -group router_if {/tb/pe_x[0]/pe_y[0]/pe_mod/router_if/data_i}
add wave -noupdate -height 19 -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/clock}
add wave -noupdate -height 19 -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/reset}
add wave -noupdate -height 19 -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/addr_in}
add wave -noupdate -height 19 -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/nbytes_in}
add wave -noupdate -height 19 -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/cmd_in}
add wave -noupdate -height 19 -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/status_out}
add wave -noupdate -height 19 -expand -group ddma_if {/tb/pe_x[0]/pe_y[0]/pe_mod/ddma_if/irq_out}
add wave -noupdate -height 19 -expand -group tcd_if {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/clock}
add wave -noupdate -height 19 -expand -group tcd_if {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/reset}
add wave -noupdate -height 19 -expand -group tcd_if {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/addr_in}
add wave -noupdate -height 19 -expand -group tcd_if {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/nbytes_in}
add wave -noupdate -height 19 -expand -group tcd_if {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/req_in}
add wave -noupdate -height 19 -expand -group tcd_if {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/ack_in}
add wave -noupdate -height 19 -expand -group tcd_if {/tb/pe_x[0]/pe_y[0]/pe_mod/tcd_if/irq_out}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9807 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 257
configure wave -valuecolwidth 100
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
