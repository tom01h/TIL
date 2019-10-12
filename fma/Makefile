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
	--prefix Vfma \

VERILATOR_MAKE_OPTS = OPT_FAST="-O3"

DESIGN_SRCS = \
lib.sv \
fmad.sv \
fmas.sv \

TOP = fma_top.sv

#TB = fmad_tb.cpp
TB = fmas_tb.cpp

default: $(SIM_DIR)/Vfma

sim: $(SIM_DIR)/Vfma

$(SIM_DIR)/Vfma: $(TOP) $(DESIGN_SRCS) $(TB)
	$(VERILATOR) $(VERILATOR_OPTS) $(TOP) $(DESIGN_SRCS) --exe ../$(TB)
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vfma.mk Vfma__ALL.a
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vfma.mk Vfma

clean:
	rm -rf sim/ tmp.vcd

.PHONY:
