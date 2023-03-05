import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import randint, seed
seed( 0xdeadbeef ) # Reproducible testing

async def count_test( dut, input, num_to_count, output ):
    dut.latch_val.value = 0
    dut.en.value = 0

    dut.in_num.value = input
    await ClockCycles( dut.clk, randint( 3, 10 ) ) # Delay - wait to start
    dut.latch_val.value = 1
    await RisingEdge( dut.clk ) # Latched
    dut.latch_val.value = 0

    await ClockCycles( dut.clk, randint( 3, 10 ) ) # Delay - wait for enable
    dut.en.value = 1

    for i in range( num_to_count ):
        await RisingEdge( dut.clk ) # Allow design to count
    dut.en.value = 0
    await ClockCycles( dut.clk, randint( 3, 10 ) ) # Delay - don't count further
    
    assert output == dut.out_num.value

@cocotb.test()
async def counter_test(dut):
    dut._log.info("start")

    # Apply a clock
    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())

    # Run tests

    # Simple tests
    await count_test( dut, 1, 0, 1 )
    await count_test( dut, 1, 1, 2 )
    await count_test( dut, 2, 2, 4 )

    # Large tests
    await count_test( dut,  4,  7, 11 )
    await count_test( dut, 13,  5, 18 )
    await count_test( dut, 20, 27, 47 )
    await count_test( dut, 42,  3, 45 )




