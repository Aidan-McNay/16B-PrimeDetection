`ifndef SRC_DIV
`define SRC_DIV

module aidan_mcnay_div #(
    parameter nbits = 16
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

    // Delegate between two division units for optimal delay
    // Credit for dynamic dispatch: Quinn Caroline Guthrie <3

    reg                itr_istream_val;
    wire               itr_istream_rdy;
    wire [nbits - 1:0] itr_result;
    wire               itr_ostream_val;

    reg istream_rdy_reg;
    assign istream_rdy = istream_rdy_reg;

    aidan_mcnay_itr_div #( .nbits(nbits) ) itr_div (
        .clk         (clk),
        .reset       (reset),

        .opa         (opa),
        .opb         (opb),
        .istream_val (itr_istream_val),
        .istream_rdy (itr_istream_rdy),

        .result      (itr_result),
        .ostream_val (itr_ostream_val),
        .ostream_rdy (ostream_rdy)
    );

    reg                shift_istream_val;
    wire               shift_istream_rdy;
    wire [nbits - 1:0] shift_result;
    wire               shift_ostream_val;

    aidan_mcnay_shift_div #( .nbits(nbits) ) shift_div (
        .clk         (clk),
        .reset       (reset),

        .opa         (opa),
        .opb         (opb),
        .istream_val (shift_istream_val),
        .istream_rdy (shift_istream_rdy),

        .result      (shift_result),
        .ostream_val (shift_ostream_val),
        .ostream_rdy (ostream_rdy)
    );

    // Determine which to use based on data - I ran some empirical results,
    // the cutoff is when a is 33.3 times larger than b, so I rounded to 32
    // for the sake of easy binary operations
    wire use_itr;
    assign use_itr = ( opa >> 5 ) < opb;

    //-------------------- Front-end --------------------

    // Ensure we can only use one at a time
    reg in_use;

    always @( posedge clk ) begin
        if( reset ) in_use <= 1'b0;

        else if( istream_val & istream_rdy ) in_use <= 1'b1;

        else if( ostream_val & ostream_rdy ) in_use <= 1'b0;
    end
    
    always @( * ) begin
        if( use_itr ) begin
            itr_istream_val   = istream_val;
            istream_rdy_reg   = itr_istream_rdy & !in_use;
            
            shift_istream_val = 1'b0;
        end

        else begin
            shift_istream_val = istream_val;
            istream_rdy_reg   = shift_istream_rdy & !in_use;
            
            itr_istream_val   = 1'b0;
        end
    end

    //-------------------- Back-end --------------------

    assign ostream_val = shift_ostream_val | itr_ostream_val;
    assign result = ( itr_ostream_val ) ? itr_result : shift_result;

endmodule

`endif // SRC_DIV