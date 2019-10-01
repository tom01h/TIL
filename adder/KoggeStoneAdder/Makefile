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
ksa.v \

VERILATOR_CPP_TB = tb.cpp

default: $(SIM_DIR)/Vksa

sim: $(SIM_DIR)/Vksa

$(SIM_DIR)/Vksa: $(DESIGN_SRCS) $(VERILATOR_CPP_TB)
	$(VERILATOR) $(VERILATOR_OPTS) $(DESIGN_SRCS) --exe ../$(VERILATOR_CPP_TB)
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vksa.mk Vksa__ALL.a
	cd sim; make $(VERILATOR_MAKE_OPTS) -f Vksa.mk Vksa

clean:
	rm -rf sim/ tmp.vcd

.PHONY:
