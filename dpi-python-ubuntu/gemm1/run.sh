#/bin/sh

vsim -c -sv_lib cimports tb -do " \
add wave -noupdate /tb/* -recursive; \
run -all;quit -f" > /dev/null &

python3 tb.py