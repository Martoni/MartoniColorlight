#! /usr/bin/python3
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
# Author:   Fabien Marteau <mail@fabienm.eu>
# Created:  07/04/2020
#-----------------------------------------------------------------------------
""" test_simpleVga
"""

import sys

import os
import sys
import cocotb
import logging
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.result import TestError
from cocotb.result import ReturnValue
from cocotb.result import raise_error
from cocotb.binary import BinaryValue
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles


class SimpleVgaTest(object):
    """
    """
    LOGLEVEL = logging.INFO
    PERIOD = (40, "ns")

    def __init__(self, dut):
        if sys.version_info[0] < 3:
            raise Exception("Must be using Python 3")
        self._dut = dut
        self._dut._log.setLevel(self.LOGLEVEL)
        self.log = dut._log
        self.log.setLevel(self.LOGLEVEL)
        self.clock = Clock(self._dut.clk_i, self.PERIOD[0], self.PERIOD[1])
        self._clock_thread = cocotb.fork(self.clock.start())

    @cocotb.coroutine
    def reset(self):
        yield RisingEdge(self._dut.clk_i)
        yield RisingEdge(self._dut.clk_i)

@cocotb.test()#skip=True)
def simple_test(dut):
    cnpt = SimpleVgaTest(dut)
    cnpt.log.info("Begin simple test")
    yield cnpt.reset()
    cnpt.log.info("Reset ok")
    yield Timer(25, units="ms")
    cnpt.log.info("End of simple test")

