`default_nettype none
`timescale 1ns/1ps

`ifndef SRC_TESTS_SIPO_TEST_TB
`define SRC_TESTS_SIPO_TEST_TB
`define SIM

`include "../sipo.v"

module sipo_test_tb #( 
    parameter nbits = 16
) (
    input  wire             clk,
    input  wire             reset,

    input  wire             en,
    input  wire             data_in,
    output wire [nbits-1:0] data_out
);

    initial begin
        $dumpfile ("sipo_test_tb.vcd");
        $dumpvars (0, sipo_test_tb);
        #1;
    end

    aidan_mcnay_sipo #( nbits ) dut (
        .*
    );

endmodule

`endif // SRC_TEST_SIPO_TEST_TB