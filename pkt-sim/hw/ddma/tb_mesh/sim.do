if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

# DMA SOURCE
vlog -mixedsvvh -sv -work work ../ddma.sv
vlog -mixedsvvh -sv -work work ../interface_router_port.sv
vlog -mixedsvvh -sv -work work ../interface_ddma.sv

# MEMORY CORE SOURCE
vlog -mixedsvvh -sv -work work ../../memory/dual_port_ram.sv
vlog -mixedsvvh -sv -work work ../../memory/interface_memory.sv


# TB DRIVERS
vlog -mixedsvvh -sv -work work ../../../packets/0.sv
vlog -mixedsvvh -sv -work work ../../../packets/1.sv
vlog -mixedsvvh -sv -work work ../../../packets/2.sv
vlog -mixedsvvh -sv -work work ../../../packets/3.sv
vlog -mixedsvvh -sv -work work ../../../packets/4.sv
vlog -mixedsvvh -sv -work work ../../../packets/5.sv
vlog -mixedsvvh -sv -work work ../../../packets/6.sv
vlog -mixedsvvh -sv -work work ../../../packets/7.sv
vlog -mixedsvvh -sv -work work ../../../packets/8.sv
# vlog -mixedsvvh -sv -work work ../../../packets/9.sv
vlog -mixedsvvh -sv -work work ../../../packets/10.sv
vlog -mixedsvvh -sv -work work ../../../packets/11.sv
vlog -mixedsvvh -sv -work work ../../../packets/12.sv
vlog -mixedsvvh -sv -work work ../../../packets/13.sv
vlog -mixedsvvh -sv -work work ../../../packets/14.sv
vlog -mixedsvvh -sv -work work ../../../packets/15.sv


# TB MODS
vlog -mixedsvvh -sv -work work ./ddma_top.sv

vsim -voptargs=+acc=lprn -t ps -debugDB work.ddma_top
#vsim -t ps -debugDB work.tb

quietly set StdArithNoWarnings 1
quietly set StdVitalGlitchNoWarnings 1

do wave.do
#view -new schematic

run 0 ns

quietly set StdArithNoWarnings 0
quietly set StdVitalGlitchNoWarnings 0

run 200 ns


