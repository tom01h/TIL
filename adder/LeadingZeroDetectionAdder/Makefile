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
lza.v \

VERILATOR_CPP_TB = tb.cpp

default: $(SIM_DIR)/Vlza

sim: $(SIM_DIR)/Vlza

$(SIM_DIR)/Vlza: $(DESIGN_SRCS) $(VERILATOR_CPP_TB)
	$(VERILATOR) $(VERILATOR_OPTS) $(DESIGN_SRCS) --exe ../$(VERILATOR_CPP_TB)
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vlza.mk Vlza__ALL.a
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vlza.mk Vlza

clean:
	rm -rf sim/ tmp.vcd

.PHONY:
