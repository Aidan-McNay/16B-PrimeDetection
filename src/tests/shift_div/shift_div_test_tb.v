`default_nettype none
`timescale 1ns/1ps

`ifndef SRC_TESTS_SHIFT_DIV_TEST_TB
`define SRC_TESTS_SHIFT_DIV_TEST_TB

`include "shift_div.v"

module shift_div_test_tb #( 
    parameter nbits = 32
) (
    input  wire               clk,
    input  wire               reset,
    
    input  wire [nbits - 1:0] opa,
    input  wire [nbits - 1:0] opb,
    input  wire               istream_val,
    output wire               istream_rdy,

    output wire [nbits - 1:0] result,
    output wire               ostream_val,
    input  wire               ostream_rdy
);

    initial begin
        $dumpfile ("shift_div_test_tb.vcd");
        $dumpvars (0, shift_div_test_tb);
        #1;
    end

    aidan_mcnay_shift_div #( .nbits(nbits) ) dut (
        .*
    );

endmodule

`endif // SRC_TEST_SHIFT_DIV_TEST_TB