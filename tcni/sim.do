if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vlog -sv -work work sv/testbench_defs.sv

vlog -sv -work work sv/interface_memory.sv
vlog -sv -work work sv/interface_tcni.sv
vlog -sv -work work sv/interface_noc.sv

vlog -sv -work work sv/tcni_receiver.sv
vlog -sv -work work sv/tcni_sender.sv

vlog -sv -work work sv/testbench.sv

vsim -voptargs=+acc=lprn -t ps work.Testbench

#set StdArithNoWarnings 1
#set StdVitalGlitchNoWarnings 1

do wave.do
run 1000 ns


