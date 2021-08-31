onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {NoC Dimension}
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/x_ROUTERS
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/Y_ROUTERS
add wave -noupdate -divider {Clock and Cycle Counter}
add wave -noupdate /injectortb/clock
add wave -noupdate /injectortb/injectors_gen(0)/Injector/reset
add wave -noupdate -radix decimal -radixshowbase 0 /injectortb/injectors_gen(0)/Injector/cycles
add wave -noupdate -divider {Injector 0}
add wave -noupdate /injectortb/injectors_gen(0)/Injector/pkt_state
add wave -noupdate -radix decimal -childformat {{/injectortb/injectors_gen(0)/Injector/pkt.start -radix decimal} {/injectortb/injectors_gen(0)/Injector/pkt.size -radix decimal} {/injectortb/injectors_gen(0)/Injector/pkt.target -radix decimal} {/injectortb/injectors_gen(0)/Injector/pkt.deadline -radix decimal}} -expand -subitemconfig {/injectortb/injectors_gen(0)/Injector/pkt.start {-height 21 -radix decimal} /injectortb/injectors_gen(0)/Injector/pkt.size {-height 21 -radix decimal} /injectortb/injectors_gen(0)/Injector/pkt.target {-height 21 -radix decimal} /injectortb/injectors_gen(0)/Injector/pkt.deadline {-height 21 -radix decimal}} /injectortb/injectors_gen(0)/Injector/pkt
add wave -noupdate /injectortb/injectors_gen(0)/Injector/clock_tx
add wave -noupdate /injectortb/injectors_gen(0)/Injector/tx
add wave -noupdate /injectortb/injectors_gen(0)/Injector/data_out
add wave -noupdate /injectortb/injectors_gen(0)/Injector/credit_i
add wave -noupdate -divider {Router 0 - input}
add wave -noupdate -height 19 -expand -group {Router 0 - In} /injectortb/noc/noc(0)/router/rx(0)
add wave -noupdate -height 19 -expand -group {Router 0 - In} /injectortb/noc/noc(0)/router/clock_rx(0)
add wave -noupdate -height 19 -expand -group {Router 0 - In} /injectortb/noc/noc(0)/router/data_in(0)
add wave -noupdate -height 19 -expand -group {Router 0 - In} /injectortb/noc/noc(0)/router/credit_o(0)
add wave -noupdate -height 19 -expand -group {Router 0 - Out} /injectortb/noc/noc(0)/router/clock_tx(0)
add wave -noupdate -height 19 -expand -group {Router 0 - Out} /injectortb/noc/noc(0)/router/tx(0)
add wave -noupdate -height 19 -expand -group {Router 0 - Out} /injectortb/noc/noc(0)/router/data_out(0)
add wave -noupdate -height 19 -expand -group {Router 0 - Out} /injectortb/noc/noc(0)/router/credit_i(0)
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {855 ps} 0}
quietly wave cursor active 1
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
WaveRestoreZoom {0 ps} {11243 ps}
