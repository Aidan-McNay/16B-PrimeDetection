import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import randint, seed
from signal import alarm
seed( 0xdeadbeef ) # Reproducible testing

async def apply_input( dut, opa, opb ):
    dut.opa.value = opa
    dut.opb.value = opb
    dut.istream_val.value = 1
    while True:
        await RisingEdge( dut.clk ) # Wait to apply the signal
        if( dut.istream_rdy.value == 1 ):
            break

    dut.istream_val.value = 0

async def get_output( dut ):
    dut.ostream_rdy.value = 1

    i = 0
    while True:
        i = i + 1
        await RisingEdge( dut.clk ) # Wait to apply the signal
        if( dut.ostream_val.value == 1 ):
            break
        if( i > 1000 ):
            break

    result = dut.result.value
    dut.ostream_rdy.value = 0
    return result

async def run_test( dut, opa, opb, result ):
    await apply_input( dut, opa, opb )
    dut_result = await get_output( dut )
    assert dut_result == result

async def run_test_delays( dut, opa, opb, result ):
    await ClockCycles( dut.clk, randint( 3, 10 ) ) # Delay
    await apply_input( dut, opa, opb )
    await ClockCycles( dut.clk, randint( 3, 10 ) ) # Delay
    dut_result = await get_output( dut )
    assert dut_result == result

@cocotb.test()
async def combo_div_test(dut):
    dut._log.info("start")

    # Apply a clock
    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the design - active high
    dut.reset.value = 1
    await ClockCycles(dut.clk, 10)
    dut.reset.value = 0

    # Run tests

    # Simple tests
    await run_test( dut, 2, 1, 0 )
    await run_test( dut, 3, 2, 1 )
    await run_test( dut, 7, 5, 2 )

    # Large tests
    await run_test( dut, 32, 14, 4  )
    await run_test( dut, 69, 13, 4  )
    await run_test( dut, 35, 12, 11 )

    # Tests with delays
    await run_test_delays( dut, 25,  8, 1 )
    await run_test_delays( dut, 42, 17, 8 )
    await run_test_delays( dut, 33,  5, 3 )

    # Test when opb is bigger than opa
    await run_test_delays( dut,  1,  2,  1 )
    await run_test_delays( dut, 14, 27, 14 )

    # Test large values to test shift division

    await run_test_delays( dut, 658944701,  3, 2 )
    await run_test_delays( dut, 860398750, 17, 3 )



