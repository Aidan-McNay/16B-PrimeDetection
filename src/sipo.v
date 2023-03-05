`ifndef SRC_SIPO
`define SRC_SIPO

`include "reg.v"

module aidan_mcnay_sipo #(
    parameter nbits = 16
) (
    input  wire             clk,
    input  wire             reset,

    input  wire             en,
    input  wire             data_in,
    output wire [nbits-1:0] data_out
);

    // A serial-in, parallel-out register, parametrized by size
    // More significant bits are those that come first

    //    .--------------------------------------.
    //    |  0 <- 1 <- . . . 0 <- 1 <- 1 <- 0 <- | <- data_in
    //    `--------------------------------------'
    //       |    |          |    |    |    |
    //       v    v          v    v    v    v
    // [nbits-1]            [3]  [2]  [1]  [0] data_out

    wire [nbits:0] register_inputs;
    assign register_inputs[0] = data_in;

    genvar i;

    generate
        for( i = 0; i < nbits; i = i + 1 ) begin: REGISTER
            aidan_mcnay_reg sipo_reg(
                .clk   ( clk ),
                .reset ( reset ),
                .en    ( en ),
                .in    ( register_inputs[ i ] ),
                .out   ( register_inputs[ i + 1 ] )
            );
        end
    endgenerate

    assign data_out = register_inputs[ nbits:1 ];

endmodule

`endif // SRC_SIPO