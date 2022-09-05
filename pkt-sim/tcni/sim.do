if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vcom -work work -93 -explicit ../hermes/Hermes_package.vhd
vcom -work work -93 -explicit ../hermes/Hermes_buffer.vhd
vcom -work work -93 -explicit ../hermes/Hermes_switchcontrol.vhd
vcom -work work -93 -explicit ../hermes/Hermes_crossbar.vhd
vcom -work work -93 -explicit ../hermes/RouterCC.vhd
vcom -work work -93 -explicit ../hermes/TopNOC.vhd

vlog -sv -work work sv/defs.sv
vlog -sv -work work sv/interface_memory.sv
vlog -sv -work work sv/interface_tcni.sv
vlog -sv -work work sv/interface_noc.sv
vlog -sv -work work sv/interface_cpu.sv
vlog -sv -work work sv/ddma.sv

vlog -sv -work work sv/tb.sv

vsim -voptargs=+acc=lprn -t ps work.tb

#set StdArithNoWarnings 1
#set StdVitalGlitchNoWarnings 1

do wave.do
run 100 ns


