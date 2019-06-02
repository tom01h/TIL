#/bin/sh

if [ ! -d work/ ]; then
    vlib.exe work
fi

vlog.exe sim_top.v tiny_dnn_core.sv tiny_dnn_buf.sv

vsim.exe -c work.sim_top -lib work -do " \
add wave -noupdate /sim_top/* -recursive; \
add wave -noupdate /sim_top/tiny_dnn_core/WM0 ; \
run 1000ns; quit"

