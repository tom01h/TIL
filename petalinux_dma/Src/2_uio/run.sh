#/bin/sh

if [ ! -d work/ ]; then
    vlib.exe work
fi

vlog.exe sim_top.v mem.v

vsim.exe -c work.sim_top -lib work -do " \
add wave -noupdate /sim_top/* -recursive; \
add wave -noupdate /sim_top/mem/mem1; \
run 1000ns; quit"

