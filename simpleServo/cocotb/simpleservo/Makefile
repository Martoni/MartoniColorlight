TOPLEVEL_LANG ?= verilog

#SIM=icarus
SIM=verilator
ifeq ($(SIM), icarus)
EXTRA_ARGS += -DICARUS_SIM
endif

ifeq ($(SIM), verilator)
COCOTB_HDL_TIMEPRECISION = 1ns
EXTRA_ARGS += --coverage
endif

export COCOTB_REDUCED_LOG_FMT=1

ifneq ($(TOPLEVEL_LANG),verilog)

all:
	@echo "Skipping example due to TOPLEVEL_LANG=$(TOPLEVEL_LANG) not being verilog"

clean::

else

TOPLEVEL=SimpleServo

ifeq ($(OS),Msys)
WPWD=$(shell sh -c 'pwd -W')
else
WPWD=$(shell pwd)
endif

PWD=$(shell pwd)

VERILOG_SOURCES = ../../hdl/simpleservo.v
MODULE=test_simpleservo

include $(shell cocotb-config --makefiles)/Makefile.inc
include $(shell cocotb-config --makefiles)/Makefile.sim

endif

mrproper:
	-rm results.xml
	-rm $(TOPLEVEL).vcd
	-rm $(TOPLEVEL).v
	-rm -rf __pycache__
	-rm -rf sim_build/
	-rm -rf build
	-rm dump.vcd
