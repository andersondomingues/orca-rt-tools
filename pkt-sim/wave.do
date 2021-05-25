onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and Cycle Counter}
add wave -noupdate /testbench/clock_rx(0)
add wave -noupdate -radix decimal /testbench/cycles
add wave -noupdate -divider {Packet State}
add wave -noupdate -expand /testbench/pkt_state
add wave -noupdate -divider {ROUTER 0}
add wave -noupdate -color {Blue Violet} /testbench/data_in(0)
add wave -noupdate -color {Blue Violet} /testbench/rx(0)
add wave -noupdate -color {Blue Violet} /testbench/credit_o(0)
add wave -noupdate /testbench/data_out(0)
add wave -noupdate /testbench/tx(0)
add wave -noupdate /testbench/credit_i(0)
add wave -noupdate -divider {ROUTER 1}
add wave -noupdate -color {Blue Violet} /testbench/data_in(1)
add wave -noupdate -color {Blue Violet} /testbench/rx(1)
add wave -noupdate -color {Blue Violet} /testbench/credit_o(1)
add wave -noupdate /testbench/data_out(1)
add wave -noupdate /testbench/tx(1)
add wave -noupdate /testbench/credit_i(1)
add wave -noupdate -divider {ROUTER 2}
add wave -noupdate -color {Blue Violet} /testbench/data_in(2)
add wave -noupdate -color {Blue Violet} /testbench/rx(2)
add wave -noupdate -color {Blue Violet} /testbench/credit_o(2)
add wave -noupdate /testbench/data_out(2)
add wave -noupdate /testbench/tx(2)
add wave -noupdate /testbench/credit_i(2)
add wave -noupdate -divider {ROUTER 3}
add wave -noupdate -color {Blue Violet} /testbench/data_in(3)
add wave -noupdate -color {Blue Violet} /testbench/rx(3)
add wave -noupdate -color {Blue Violet} /testbench/credit_o(3)
add wave -noupdate /testbench/data_out(3)
add wave -noupdate /testbench/tx(3)
add wave -noupdate /testbench/credit_i(3)
add wave -noupdate -divider <NULL>
add wave -noupdate -childformat {{/testbench/count_size(0) -radix unsigned} {/testbench/count_size(1) -radix unsigned} {/testbench/count_size(2) -radix unsigned} {/testbench/count_size(3) -radix unsigned} {/testbench/count_size(4) -radix unsigned}} -expand -subitemconfig {/testbench/count_size(0) {-height 17 -radix unsigned} /testbench/count_size(1) {-height 17 -radix unsigned} /testbench/count_size(2) {-height 17 -radix unsigned} /testbench/count_size(3) {-height 17 -radix unsigned} /testbench/count_size(4) {-height 17 -radix unsigned}} /testbench/count_size
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {140 ns}

