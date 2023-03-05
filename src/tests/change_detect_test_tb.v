`default_nettype none
`timescale 1ns/1ps

`ifndef SRC_TESTS_CHANGE_DETECT_TEST_TB
`define SRC_TESTS_CHANGE_DETECT_TEST_TB

`include "../change_detect.v"

module change_detect_test_tb (
    input  wire clk,
    input  wire in_signal,
    output wire out_signal
);

    initial begin
        $dumpfile ("change_detect_test_tb.vcd");
        $dumpvars (0, change_detect_test_tb);
        #1;
    end

    aidan_mcnay_change_detect dut (
        .*
    );

endmodule

`endif // SRC_TEST_CHANGE_DETECT_TEST_TB