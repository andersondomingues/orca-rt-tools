if {[file isdirectory work]} { vdel -all -lib work }

vlib work
vmap work work

vcom -work work -93 -explicit hermes/Hermes_package.vhd
vcom -work work -93 -explicit hermes/Hermes_buffer.vhd
vcom -work work -93 -explicit hermes/Hermes_switchcontrol.vhd
vcom -work work -93 -explicit hermes/Hermes_crossbar.vhd
vcom -work work -93 -explicit hermes/RouterCC.vhd
vcom -work work -93 -explicit hermes/TopNOC.vhd
vcom -work work -93 -explicit injector/text_util.vhd
vcom -work work -93 -explicit injector/Injector.vhd
vcom -work work -93 -explicit injector/InjectorTB.vhd

vsim -voptargs=+acc=lprn -t ps work.InjectorTB

set StdArithNoWarnings 1
set StdVitalGlitchNoWarnings 1

do injector_wave.do

run 140 ns

