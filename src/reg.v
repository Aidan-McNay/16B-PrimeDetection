`ifndef SRC_REG
`define SRC_REG

module aidan_mcnay_reg (
    input  wire clk,
    input  wire reset,

    input  wire en,
    input  wire in,
    output wire out
);

    // One-bit enabled register with synchronous reset

    reg value;

    always @( posedge clk ) begin
        if( reset )
            value <= 0;
        else if ( en )
            value <= in;
    end

    assign out = value;

endmodule

`endif // SRC_REG