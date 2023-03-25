`default_nettype none
`timescale 1ns/1ps

`ifndef SRC_TESTS_PRIMEDETECTOR_TEST_TB
`define SRC_TESTS_PRIMEDETECTOR_TEST_TB

`include "PrimeDetector.v"

module PrimeDetector_test_tb #( 
    parameter nbits = 31
) (
    input  wire io_in_0,
    input  wire io_in_1,
    input  wire io_in_2,
    input  wire io_in_3,
    input  wire io_in_4,
    input  wire io_in_5,
    input  wire io_in_6,
    input  wire io_in_7,

    output wire io_out_0,
    output wire io_out_1,
    output wire io_out_2,
    output wire io_out_3,
    output wire io_out_4,
    output wire io_out_5,
    output wire io_out_6,
    output wire io_out_7
);

    initial begin
        $dumpfile ("PrimeDetector_test_tb.vcd");
        $dumpvars (0, PrimeDetector_test_tb);
        #1;
    end

    wire [7:0] io_in;
    wire [7:0] io_out;

    assign io_in[0] = io_in_0;
    assign io_in[1] = io_in_1;
    assign io_in[2] = io_in_2;
    assign io_in[3] = io_in_3;
    assign io_in[4] = io_in_4;
    assign io_in[5] = io_in_5;
    assign io_in[6] = io_in_6;
    assign io_in[7] = io_in_7;

    assign io_out_0 = io_out[0];
    assign io_out_1 = io_out[1];
    assign io_out_2 = io_out[2];
    assign io_out_3 = io_out[3];
    assign io_out_4 = io_out[4];
    assign io_out_5 = io_out[5];
    assign io_out_6 = io_out[6];
    assign io_out_7 = io_out[7];

    aidan_mcnay_PrimeDetector #( .nbits(nbits) ) dut (
        .*
    );

endmodule

`endif // SRC_TEST_SIPO_TEST_TB