import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles, Combine
from random import randint, seed
import signal
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

async def shift_in_value( dut, value ):
    dut.io_in_4.value = 1
    value_list = gen_list( value )

    for value_bit in value_list:
        await ClockCycles( dut.io_in_3, randint( 3, 10 ) ) # Delay - make sure we don't get extra data
        dut.io_in_4.value = 0 # Enable
        dut.io_in_2.value = value_bit # Data bit
        await ClockCycles( dut.io_in_3, 1 ) # Data is in
        dut.io_in_4.value = 1 # Enable


async def PrimeDetector_value_test( dut, number, is_prime ):
    await shift_in_value( dut, number )
    await ClockCycles( dut.io_in_0, randint( 0, 3 ) ) # Random delay

    # Tell the design we're ready
    dut.io_in_5.value = 1 # Ready bit
    await ClockCycles( dut.io_in_0, randint( 4, 10 ) ) # Random delay
    dut.io_in_5.value = 0 # Ready bit

    # Wait for the design to be done
    i = 0
    while True:
        i = i + 1
        await RisingEdge( dut.io_in_0 )
        if( dut.io_out_0 == 1 ):
            break

    # Check that we got the right value
    if is_prime:
        assert dut.io_out_1 == 1
    else:
        assert dut.io_out_1 == 0

@cocotb.test()
async def PrimeDetector_test(dut):
    dut._log.info("start")
    print( dut )

    # Timeout
    signal.alarm( 60 )

    # Apply a clock
    clock = Clock(dut.io_in_0, 1, units="ns")
    cocotb.start_soon(clock.start())

    # Apply user input clock
    clock = Clock(dut.io_in_3, 20, units="ns")
    cocotb.start_soon(clock.start())

    # Set input enable and ready bit to be low
    dut.io_in_4.value = 1 # Enable - active low
    dut.io_in_5.value = 0 # Ready bit

    # Reset the design - active high
    dut.io_in_1.value = 1
    await ClockCycles(dut.io_in_3, 5)
    dut.io_in_1.value = 0

    # Make sure that done is 0
    assert dut.io_out_0.value == 0

    # Run tests

    # Simple tests
    await PrimeDetector_value_test( dut, 3, True  )
    await PrimeDetector_value_test( dut, 4, False )
    await PrimeDetector_value_test( dut, 5, True  )

    # Larger tests
    await PrimeDetector_value_test( dut,  57, False )
    await PrimeDetector_value_test( dut,  31, True  )
    await PrimeDetector_value_test( dut,  69, False )
    await PrimeDetector_value_test( dut, 877, True  )
    await PrimeDetector_value_test( dut, 943, False )

    # Base cases
    await PrimeDetector_value_test( dut, 2, True  )
    await PrimeDetector_value_test( dut, 1, False )
    await PrimeDetector_value_test( dut, 0, False )

    # # Test larger range
    # await PrimeDetector_value_test( dut,      65537, True  )
    # await PrimeDetector_value_test( dut, 4294967295, False )
    # await PrimeDetector_value_test( dut, 4294967291, True  ) # Takes super long
    # await PrimeDetector_value_test( dut, 4294967289, False )
 