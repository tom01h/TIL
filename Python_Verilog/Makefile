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
add.sv \

VERILATOR_CPP_TB = tb.cpp

default: $(SIM_DIR)/Vadd

sim: $(SIM_DIR)/Vadd

$(SIM_DIR)/Vadd: $(DESIGN_SRCS) $(VERILATOR_CPP_TB)
	$(VERILATOR) $(VERILATOR_OPTS) $(DESIGN_SRCS) --exe ../$(VERILATOR_CPP_TB)
	cp /usr/local/share/verilator/include/verilated.cpp .
	cp /usr/local/share/verilator/include/verilated_vcd_c.cpp .
	python3 setup.py build_ext -I/usr/local/share/verilator/include -i

clean:
	rm -rf build/ sim/ tmp.vcd *.so cp verilated.cpp verilated_vcd_c.cpp

.PHONY:
