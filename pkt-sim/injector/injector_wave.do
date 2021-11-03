onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {NoC Dimension}
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/x_ROUTERS
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/Y_ROUTERS
add wave -noupdate -divider {Clock and Cycle Counter}
add wave -noupdate /injectortb/clock
add wave -noupdate /injectortb/injectors_gen(0)/Injector/reset
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/cycles
add wave -noupdate -expand /injectortb/data_inArray
add wave -noupdate -expand /injectortb/data_outArray
add wave -noupdate -expand /injectortb/pkt_oArray
add wave -noupdate -expand /injectortb/pkt_state_oArray
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119972 ps} 1} {{Cursor 2} {141949 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 105
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
WaveRestoreZoom {114400 ps} {156486 ps}
