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
    # Real period is 40ns
    PERIOD = (5, "us")
    SUPER_NES_LEN = 16
    NES_LEN = 8

    def __init__(self, dut, reg_init_value=None, reg_len=16):
        if sys.version_info[0] < 3:
            raise Exception("Must be using Python 3")
        if reg_init_value is None:
            raise Exception("Give list of values")
        self._dut = dut
        self._reglen = reg_len
        self.log = dut._log
        self.log.setLevel(self.LOGLEVEL)
        self.reg_init_value = reg_init_value
        self._reg = None
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
        """ register mecanics """
        # wait for the end of rst
        yield FallingEdge(self._dut.rst_i)
        # will loop
        while True:
            dlatch = int(self._dut.dlatch_o)
            if dlatch != 0:
                if self.reg_init_value == []:
                    return
                self._current = self.reg_init_value.pop()
                self._reg = self._current
                self._regcnt = self._reglen
                self.log.info("Reg {:02X}".format(self._reg))
                sdata_bit = (self._reg & 0x8000)
                self.log.info("Latching {:04X}".format(self._reg))
                self._dut.sdata_i <= (sdata_bit != 0)
                self.log.info(f"sdata_bit {sdata_bit} (dlatch)")
                yield FallingEdge(self._dut.dlatch_o)
            else:
                clock_rise = RisingEdge(self._dut.dclock_o)
                dlatch_rise = RisingEdge(self._dut.dlatch_o)

                trigg = yield [clock_rise, dlatch_rise]
                if trigg == clock_rise:
                    self.log.info("--> clock rise ")
                if trigg == dlatch_rise:
                    self.log.info("--> latch rise ")
                if self._regcnt != self._reglen:
                    self._reg = (self._reg << 1) & 0xFFFF
                self._regcnt = self._regcnt - 1
                self.log.info(f"Counter {self._regcnt}")
                self.log.info("Reg {:02X}".format(self._reg))
                sdata_bit = self._reg & 0x8000
                self._dut.sdata_i <= (sdata_bit != 0)
                self.log.info(f"sdata_bit {self._dut.sdata_i}")

@cocotb.test()#skip=True)
def simple_test(dut):
    values = [0xAAAA, 0x5555, 0x1234, 0xAAAB]
    cnpt = SNesPadTest(dut, reg_init_value=values.copy())
    yield cnpt.reset()
    cnpt.log.info("Out of reset")
    while values != []:
        expectValue = values.pop()
        cnpt.log.info("Info value to read {:04X}".format(expectValue))
        yield RisingEdge(dut.dlatch_o)
        vread = int(dut.vdata_o)
        if vread != expectValue:
            msg = ("Wrong value read {:04X}, should be {:04X}"
                    .format(vread, expectValue))
            cnpt.log.error(msg)
            raise TestError(msg)
        cnpt.log.info("Value read {:04X}".format(vread))
        yield Timer(1, units="us")


