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

VERILATOR_MAKE_OPTS = OPT_FAST="-O3"

DESIGN_SRCS = \
cla.v \

VERILATOR_CPP_TB = tb.cpp

default: $(SIM_DIR)/Vcla

sim: $(SIM_DIR)/Vcla

$(SIM_DIR)/Vcla: $(DESIGN_SRCS) $(VERILATOR_CPP_TB)
	$(VERILATOR) $(VERILATOR_OPTS) $(DESIGN_SRCS) --exe ../$(VERILATOR_CPP_TB)
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vcla.mk Vcla__ALL.a
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vcla.mk Vcla

clean:
	rm -rf sim/ tmp.vcd

.PHONY:
