if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

# NOC SOURCE
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_package.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_buffer.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_switchcontrol.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/Hermes_crossbar.vhd
vcom -mixedsvvh -work work -93 -explicit ./hw/router/hermes/RouterCC.vhd
vlog -mixedsvvh -sv -work work ./hw/router/interface_router.sv
vlog -mixedsvvh -sv -work work ./hw/router/router.sv

# DMA SOURCE
vlog -mixedsvvh -sv -work work ./hw/ddma/ddma.sv
vlog -mixedsvvh -sv -work work ./hw/ddma/interface_router_port.sv
vlog -mixedsvvh -sv -work work ./hw/ddma/interface_ddma.sv

# MMIO SOURCE
vlog -mixedsvvh -sv -work work ./hw/mmio/mmio.sv

# TCD SOURCE
vlog -mixedsvvh -sv -work work ./hw/tcd/tcd.sv
vlog -mixedsvvh -sv -work work ./hw/tcd/interface_tcd.sv

# MEMORY CORE SOURCE
vlog -mixedsvvh -sv -work work ./hw/memory/dual_port_ram.sv
vlog -mixedsvvh -sv -work work ./hw/memory/interface_memory.sv

# CPU SOURCE
vlog -mixedsvvh -sv -work work ./hw/cpu/interface_cpu.sv

# PE AND TESTBENCH
vlog -mixedsvvh -sv -work work ./hw/pe.sv
vlog -mixedsvvh -sv -work work ./hw/interface_pe.sv
vlog -mixedsvvh -sv -work work -suppress 2583 ./hw/tb.sv

#vsim -voptargs=+acc=lprn -t ps -debugDB work.tb
vsim -t ps -debugDB work.tb

#set StdArithNoWarnings 1
#set StdVitalGlitchNoWarnings 1

do wave.do
run 100 ns


