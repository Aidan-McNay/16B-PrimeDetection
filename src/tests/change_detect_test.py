import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import randint, seed
seed( 0xdeadbeef ) # Reproducible testing

async def sequence_test( dut, input1, input2, output ):
    dut.in_signal.value = input1
    await RisingEdge( dut.clk )
    await ClockCycles( dut.clk, randint( 0, 3 ) ) # Some random delay
    dut.in_signal.value = input2
    await RisingEdge( dut.clk )
    await Timer( 1, units = "ps") # Propagation between modules lol
    assert dut.out_signal.value == output


@cocotb.test()
async def change_detect_test(dut):
    dut._log.info("start")

    # Apply a clock
    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())

    # Run tests

    await sequence_test( dut, 0, 0, 0 )
    await sequence_test( dut, 0, 1, 1 )
    await sequence_test( dut, 1, 0, 1 )
    await sequence_test( dut, 0, 0, 0 )




