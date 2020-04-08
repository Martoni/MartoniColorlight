#! /usr/bin/python3
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
# Author:   Fabien Marteau <mail@fabienm.eu>
# Created:  07/04/2020
#-----------------------------------------------------------------------------
""" test_simpleservo
"""

import sys

import os
import sys
import cocotb
import logging
from cocotb import SimLog
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.result import TestError
from cocotb.result import ReturnValue
from cocotb.result import raise_error
from cocotb.binary import BinaryValue
from cocotb.triggers import RisingEdge
from cocotb.triggers import FallingEdge
from cocotb.triggers import ClockCycles


class SimpleServoTest(object):
    """
    """
    LOGLEVEL = logging.INFO
    PERIOD = (40, "ns")

    def __init__(self, dut, reg_init_value=0xcafe, reg_len=16):
        if sys.version_info[0] < 3:
            raise Exception("Must be using Python 3")
        self._dut = dut
        self._dut._log.setLevel(self.LOGLEVEL)
        self.log = SimLog("SimpleServo.{}".format(self.__class__.__name__))
        self.log.setLevel(self.LOGLEVEL)
        self.reg_init_value = reg_init_value
        self.clock = Clock(self._dut.clk_i, self.PERIOD[0], self.PERIOD[1])
        self._clock_thread = cocotb.fork(self.clock.start())

    @cocotb.coroutine
    def reset(self):
        short_per = Timer(100, units="ns")
        self._dut.rst_i <= 1
        yield short_per
        self._dut.rst_i <= 0
        yield short_per

@cocotb.test(skip=True)
def simple_test(dut):
    cnpt = SimpleServoTest(dut)
    yield cnpt.reset()
    cnpt._dut.en_i <= 1
    cnpt._dut.position_i <= 128
    yield Timer(1, units="us")
    yield Timer(43, units="ms")

@cocotb.test()#skip=True)
def verilator_test(dut):
    cnpt = SimpleServoTest(dut)
    cnpt.log.info("Testing verilator simulation")
    yield cnpt.reset()
    cnpt._dut.en_i <= 1
    cnpt._dut.position_i <= 128
    yield Timer(1, units="us")
    yield Timer(43, units="ms")
