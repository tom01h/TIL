#/bin/sh

rm -r __pycache__/ work/ top.o cimports.so

vlib work

vlog -sv -dpiheader dpiheader.h tb.v top.v buf.sv control.sv core.sv ex_ctl.sv loop_lib.sv

g++ -m32 -c -fpic -I'/eda/intelFPGA_pro/20.3/modelsim_ase/include/' top.cpp
g++ -m32 -shared -o cimports.so top.o -L'/eda/intelFPGA_pro/20.3/modelsim_ase/linux32aloem'

dd if=/dev/zero of=tb.txt bs=1K count=1

vsim -c -sv_lib cimports tb -do " \
add wave -noupdate /tb/* -recursive; \
run 10us;quit -f" > /dev/null &

python3 tb.py