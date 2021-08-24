onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {NoC Dimension}
add wave -noupdate /injectortb/injectors_gen(0)/Injector/x_ROUTERS
add wave -noupdate /injectortb/injectors_gen(0)/Injector/Y_ROUTERS
add wave -noupdate -divider {Clock and Cycle Counter}
add wave -noupdate /injectortb/clock
add wave -noupdate /injectortb/injectors_gen(0)/Injector/cycles
add wave -noupdate -divider {Injector 0}
add wave -noupdate /injectortb/injectors_gen(0)/Injector/reset
add wave -noupdate /injectortb/injectors_gen(0)/Injector/clock_tx
add wave -noupdate /injectortb/injectors_gen(0)/Injector/tx
add wave -noupdate /injectortb/injectors_gen(0)/Injector/data_out
add wave -noupdate /injectortb/injectors_gen(0)/Injector/credit_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6000 ps} 0}
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
WaveRestoreZoom {0 ps} {140 ns}
