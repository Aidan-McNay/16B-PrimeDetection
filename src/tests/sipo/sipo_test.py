import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from random import randint, seed
seed( 0xdeadbeef ) # Reproducible testing

def gen_list( value ):
    # Generates a 16-bit long list of the value as binary numbers
    # MSB is first in the list
    return_list = []
    for i in range( 32, 0, -1 ):
        test_value = 2 ** ( i - 1 )

        if( value >= test_value ):
            return_list.append( 1 )
            value = value - test_value
        else:
            return_list.append( 0 )
    return return_list

async def sipo_value_test( dut, value ):
    value_list = gen_list( value )
    dut.en.value = 0
    print( value_list )

    for value_bit in value_list:
        await ClockCycles( dut.clk, randint( 3, 10 ) ) # Delay - make sure we don't get extra data
        dut.en.value = 1
        dut.data_in.value = value_bit
        await RisingEdge( dut.clk ) # Data is in
        dut.en.value = 0

    await Timer( 1, units = "ps") # Propagation between modules lol
    
    assert dut.data_out.value == value

@cocotb.test()
async def sipo_test(dut):
    dut._log.info("start")

    # Apply a clock
    clock = Clock(dut.clk, 1, units="ns")
    cocotb.start_soon(clock.start())

    # Reset the design - active high
    dut.reset.value = 1
    await ClockCycles(dut.clk, 10)
    dut.reset.value = 0
    assert dut.data_out.value == 0

    # Run tests

    # Simple tests
    await sipo_value_test( dut, 1 )
    await sipo_value_test( dut, 2 )
    await sipo_value_test( dut, 7 )

    # Larger tests
    await sipo_value_test( dut, 69 )
    await sipo_value_test( dut, 42 )
    await sipo_value_test( dut, 65535 ) # Largest possible number




