if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

# NOC SOURCE
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_package.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_buffer.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_switchcontrol.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_crossbar.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/RouterCC.vhd
vlog -mixedsvvh -sv -work work ./hw/router/router.sv

# DMA SOURCE
vlog -mixedsvvh -sv -work work ./hw/ddma/ddma.sv

# INTERFACES AND PE 
vlog -mixedsvvh -sv -work work ./hw/interface_memory.sv
vlog -mixedsvvh -sv -work work ./hw/interface_tcd.sv
vlog -mixedsvvh -sv -work work ./hw/interface_router.sv
vlog -mixedsvvh -sv -work work ./hw/interface_cpu.sv
vlog -mixedsvvh -sv -work work ./hw/pe.sv

# PE INTERFACE AND TB
vlog -mixedsvvh -sv -work work ./hw/interface_pe.sv
vlog -mixedsvvh -sv -work work -suppress 2583 ./hw/tb.sv

#vsim -voptargs=+acc=lprn -t ps -debugDB work.tb
vsim -t ps -debugDB work.tb

#set StdArithNoWarnings 1
#set StdVitalGlitchNoWarnings 1

do wave.do
run 100 ns


