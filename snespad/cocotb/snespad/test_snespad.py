#! /usr/bin/python3
# -*- coding: utf-8 -*-
#-----------------------------------------------------------------------------
# Author:   Fabien Marteau <mail@fabienm.eu>
# Created:  10/12/2019
#-----------------------------------------------------------------------------
# Copied from chisnespad project:
# https://github.com/Martoni/chisNesPad/blob/master/cocotb/chisnespad/test_chisnespad.py
#
""" test_nespad
"""

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


class SNesPadTest(object):
    """
    """
    LOGLEVEL = logging.INFO
    PERIOD = (40, "ns")
    SUPER_NES_LEN = 16
    NES_LEN = 8

    def __init__(self, dut, reg_init_value=0xcafe, reg_len=16):
        if sys.version_info[0] < 3:
            raise Exception("Must be using Python 3")
        self._dut = dut
        self.log = dut._log
        self.log.setLevel(self.LOGLEVEL)
        self.reg_init_value = reg_init_value
        self._reg = reg_init_value
        self._reg_count = reg_len
        self._reg_len = reg_len
        self.clock = Clock(self._dut.clk_i, self.PERIOD[0], self.PERIOD[1])
        self._clock_thread = cocotb.fork(self.clock.start())
        self._register_thread = cocotb.fork(self._register())

    @cocotb.coroutine
    def reset(self):
        short_per = Timer(100, units="ns")
        self._dut.rst_i <= 1
        self._dut.sdata_i <= 0
        yield short_per
        self._dut.rst_i <= 1
        yield short_per
        self._dut.rst_i <= 0
        yield short_per

    @cocotb.coroutine
    def _register(self):

        while True:
            try:
                dlatch = int(self._dut.dlatch_o)
            except ValueError:
                dlatch = 1
            if dlatch != 0:
                yield FallingEdge(self._dut.dlatch_o)
                self._reg = self.reg_init_value
                self._reg_count = self._reg_len
                sdata_bit = (self.reg_init_value & (0x1<<(self._reg_len-1))) >> (self._reg_len - 1)
                self._dut.sdata_i <= sdata_bit
            else:
                sdata_bit = self._reg & (0x1<<(self._reg_len-1))
                self._dut.sdata_i <= (sdata_bit != 0)
                if self._reg_count != 0:
                    self._reg = (self._reg << 1)
                yield RisingEdge(self._dut.dclock_o)

@cocotb.test()#skip=True)
def simple_test(dut):
    cnpt = SNesPadTest(dut)
    yield cnpt.reset()
    cnpt.log.info("Out of reset")
    yield Timer(500, units="us")
    cnpt.log.info("half clock")
    yield Timer(30, units="ms")
    vread = int(dut.vdata_o)
    if vread != cnpt.reg_init_value:
        msg = ("Wrong value read {:04X}, should be {:04X}"
                .format(vread, cnpt.reg_init_value))
        cnpt.log.error(msg)
        raise TestError(msg)
    cnpt.log.info("Value read {:04X}".format(vread))
    yield Timer(1, units="us")


