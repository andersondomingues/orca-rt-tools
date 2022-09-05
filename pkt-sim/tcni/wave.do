onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clock
add wave -noupdate /tb/reset
add wave -noupdate -height 19 -expand -group {Memory Interface} /tb/mem_if/clock
add wave -noupdate -height 19 -expand -group {Memory Interface} /tb/mem_if/reset
add wave -noupdate -height 19 -expand -group {Memory Interface} /tb/mem_if/data_in
add wave -noupdate -height 19 -expand -group {Memory Interface} /tb/mem_if/addr_in
add wave -noupdate -height 19 -expand -group {Memory Interface} /tb/mem_if/data_out
add wave -noupdate -height 19 -expand -group {Memory Interface} /tb/mem_if/wb_in
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/clock
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/reset
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/clock_tx
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/tx
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/credit_i
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/data_o
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/clock_rx
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/rx
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/credit_o
add wave -noupdate -height 19 -expand -group {Noc Interface} /tb/noc_if/data_i
add wave -noupdate -height 19 -expand -group {TCNI Interface} /tb/tcni_if/clock
add wave -noupdate -height 19 -expand -group {TCNI Interface} /tb/tcni_if/reset
add wave -noupdate -height 19 -expand -group {TCNI Interface} /tb/tcni_if/addr_out
add wave -noupdate -height 19 -expand -group {TCNI Interface} /tb/tcni_if/nbytes_out
add wave -noupdate -height 19 -expand -group {TCNI Interface} /tb/tcni_if/cmd
add wave -noupdate -height 19 -expand -group {TCNI Interface} /tb/tcni_if/status
add wave -noupdate -height 19 -expand -group {CPU Interface} /tb/cpu_if/clock
add wave -noupdate -height 19 -expand -group {CPU Interface} /tb/cpu_if/reset
add wave -noupdate -height 19 -expand -group {CPU Interface} /tb/cpu_if/data_in
add wave -noupdate -height 19 -expand -group {CPU Interface} /tb/cpu_if/data_out
add wave -noupdate -height 19 -expand -group {CPU Interface} /tb/cpu_if/irq
add wave -noupdate -height 19 -expand -group {CPU Interface} /tb/cpu_if/addr_out
add wave -noupdate -height 19 -expand -group {CPU Interface} /tb/cpu_if/wb_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {99125 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 164
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
WaveRestoreZoom {0 ps} {103494 ps}
