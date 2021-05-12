if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vcom -work work -93 -explicit hermes/Hermes_package.vhd
vcom -work work -93 -explicit hermes/Hermes_buffer.vhd
vcom -work work -93 -explicit hermes/Hermes_switchcontrol.vhd
vcom -work work -93 -explicit hermes/Hermes_crossbar.vhd
vcom -work work -93 -explicit hermes/RouterCC.vhd
vcom -work work -93 -explicit hermes/TopNOC.vhd
vcom -work work -93 -explicit Testbench.vhd

vsim -voptargs=+acc=lprn -t ns work.Testbench

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

do wave.do
run 20 ns

