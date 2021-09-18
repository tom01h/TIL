#/bin/sh

export WSLENV=PYTHONPATH/l
export PYTHONPATH=$PWD

vsim.exe -c -sv_lib cimports tb -do " \
add wave -noupdate /tb/* -recursive; \
run -all;quit -f" > /dev/null &

python.exe tb.py