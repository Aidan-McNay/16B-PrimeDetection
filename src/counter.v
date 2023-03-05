`ifndef SRC_COUNTER
`define SRC_COUNTER

module aidan_mcnay_counter #(
    parameter nbits = 16
) (
    input  wire             clk,
    input  wire [nbits-1:0] in_num,
    input  wire             latch_val,
    input  wire             en,
    output wire [nbits-1:0] out_num
);

    // Registers in_num when latch_val is high, and 
    // increments with clk when en is high

    reg [nbits-1:0] counter_val;

    always @( posedge clk ) begin
        if( latch_val )
            counter_val <= in_num;
        else if ( en )
            counter_val <= counter_val + 1;
    end

    assign out_num = counter_val;

endmodule

`endif // SRC_COUNTER