onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and Cycle Counter}
add wave -noupdate /testbench/clock(0)
add wave -noupdate -radix decimal /testbench/cycles
add wave -noupdate -divider {Packet State}
add wave -noupdate -expand /testbench/pkt_state
add wave -noupdate -divider {Local Router Interface}
add wave -noupdate -expand /testbench/tx
add wave -noupdate /testbench/data_in
add wave -noupdate /testbench/rx
add wave -noupdate /testbench/data_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4 ns} 0} {{Cursor 3} {6 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 178
configure wave -valuecolwidth 130
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {28 ns}
