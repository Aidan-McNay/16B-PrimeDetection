`default_nettype none
`timescale 1ns/1ps

`ifndef SRC_TESTS_COUNTER_TEST_TB
`define SRC_TESTS_COUNTER_TEST_TB

`include "../counter.v"

module counter_test_tb #( 
    parameter nbits = 16
) (
    input  wire             clk,
    input  wire [nbits-1:0] in_num,
    input  wire             latch_val,
    input  wire             en,
    output wire [nbits-1:0] out_num
);

    initial begin
        $dumpfile ("counter_test_tb.vcd");
        $dumpvars (0, counter_test_tb);
        #1;
    end

    aidan_mcnay_counter #( nbits ) dut (
        .*
    );

endmodule

`endif // SRC_TEST_COUNTER_TEST_TB