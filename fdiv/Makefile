SHELL = /bin/bash

SIM_DIR = sim

VERILATOR = verilator

VERILATOR_OPTS = \
	-Wall \
	-Wno-WIDTH \
	-Wno-UNUSED \
	-Wno-BLKSEQ \
	--cc \
	+1364-2001ext+v \
	-Wno-fatal \
	--Mdir sim \
	--trace \
	--prefix Vfdiv \

VERILATOR_MAKE_OPTS = OPT_FAST="-O3"

TOP = fdiv2.sv

TB = fdiv_tb.cpp

default: $(SIM_DIR)/Vfdiv

sim: $(SIM_DIR)/Vfdiv

$(SIM_DIR)/Vfdiv: $(TOP) $(TB)
	$(VERILATOR) $(VERILATOR_OPTS) $(TOP) --exe ../$(TB)
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vfdiv.mk Vfdiv__ALL.a
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vfdiv.mk Vfdiv

clean:
	rm -rf sim/ tmp.vcd

.PHONY:
