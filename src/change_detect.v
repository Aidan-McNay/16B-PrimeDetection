`ifndef SRC_CHANGE_DETECT
`define SRC_CHANGE_DETECT

module aidan_mcnay_change_detect (
    input  wire clk,
    input  wire in_signal,
    output wire out_signal
);

    // Detect when the input changes from a 0 to a 1

    reg in_sig_1;
    reg in_sig_2;

    always @( posedge clk ) begin
        in_sig_1 <= in_signal;
        in_sig_2 <= in_sig_1;
    end

    assign out_signal = ( in_sig_1 & !in_sig_2 );

endmodule

`endif // SRC_CHANGE_DETECT