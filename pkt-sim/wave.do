onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {NoC Dimension}
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/x_ROUTERS
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/Y_ROUTERS
add wave -noupdate -divider {Clock and Cycle Counter}
add wave -noupdate /injectortb/noc/noc(0)/router/data_in(4)
add wave -noupdate /injectortb/noc/noc(0)/router/data_out(4)
add wave -noupdate /injectortb/clock
add wave -noupdate /injectortb/injectors_gen(0)/Injector/reset
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/cycles
add wave -noupdate /injectortb/data_inArray
add wave -noupdate /injectortb/noc/noc(0)/router/rx(4)
add wave -noupdate /injectortb/noc/noc(0)/router/credit_o(4)
add wave -noupdate /injectortb/noc/noc(0)/router/credit_i(4)
add wave -noupdate /injectortb/noc/noc(0)/router/tx(4)
add wave -noupdate /injectortb/noc/noc(1)/router/tx(4)
add wave -noupdate /injectortb/noc/noc(2)/router/tx(4)
add wave -noupdate /injectortb/noc/noc(3)/router/tx(4)
add wave -noupdate /injectortb/noc/noc(0)/router/rx(4)
add wave -noupdate /injectortb/noc/noc(1)/router/rx(4)
add wave -noupdate /injectortb/noc/noc(2)/router/rx(4)
add wave -noupdate /injectortb/noc/noc(3)/router/rx(4)
add wave -noupdate -expand /injectortb/noc/noc(0)/router/FLocal/buf
add wave -noupdate /injectortb/noc/noc(1)/router/FWest/buf
add wave -noupdate /injectortb/noc/noc(2)/router/FWest/buf
add wave -noupdate /injectortb/data_outArray(0)
add wave -noupdate /injectortb/noc/noc(0)/router/data_out(0)
add wave -noupdate /injectortb/noc/noc(1)/router/data_out(0)
add wave -noupdate -expand /injectortb/data_outArray
add wave -noupdate -expand /injectortb/pkt_oArray
add wave -noupdate /injectortb/pkt_oArray(0)
add wave -noupdate -expand /injectortb/pkt_state_oArray
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {119972 ps} 1} {{Cursor 2} {13462 ps} 0} {{Cursor 3} {173012 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 352
configure wave -valuecolwidth 367
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {78496 ps}
