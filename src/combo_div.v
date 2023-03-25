`ifndef SRC_COMBO_DIV
`define SRC_COMBO_DIV

module aidan_mcnay_combo_div #(
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

    // A combination of iterative and shifting dividers, to
    // save on register space

    // Credit for the idea of dynamic dispatch based on
    // data: Quinn Caroline Guthrie <3

    // Define FSM states

    localparam IDLE       = 3'd0;
    localparam SHIFT_OPB  = 3'd1;
    localparam SHIFT_CALC = 3'd2;
    localparam ITR_CALC   = 3'd3;
    localparam DONE       = 3'd4;

    // Define datapath nets

    reg  [nbits-1:0] opa_reg;
    reg  [nbits-1:0] opb_reg;

    wire [nbits-1:0] opb_reg_sl;
    assign opb_reg_sl = opb_reg << 1;

    wire [nbits-1:0] subtracted_val;

    //--------------------Control Logic--------------------

    // Define FSM transitions

    reg  [2:0] state_curr;
    reg  [2:0] state_next;

    always @( posedge clk ) begin
        state_curr <= state_next;
    end

    always @( * ) begin
        
        if( reset )
            state_next = IDLE;

        else if( state_curr == IDLE ) begin

            if( istream_val ) begin

                if( opb > opa ) // Early exit
                    state_next = DONE;

                else if( ( opa >> 5 ) < opb ) // Use iterative divider
                    state_next = ITR_CALC;

                // Use shift divider
                else if( opb_reg[nbits-1] == 1 ) // Already shifted left
                    state_next = SHIFT_CALC;

                else state_next = SHIFT_OPB;
            end

            else state_next = state_curr;
        end

        else if( state_curr == SHIFT_OPB ) begin

            if( opb_reg[nbits-2] == 1'b1 ) // MSB will be 1 once shifted
                state_next = SHIFT_CALC;

            else if( opb_reg_sl > opa_reg ) // Don't need to shift any more after this
                state_next = SHIFT_CALC;

            else state_next = state_curr;
        end

        else if( state_curr == SHIFT_CALC ) begin
            if( opb_reg == opb )
                state_next = DONE;

            else if( opb_reg == opa_reg ) // Early exit
                state_next = DONE;

            else state_next = state_curr;
        end

        else if( state_curr == ITR_CALC ) begin
            if( subtracted_val < opb_reg )
                state_next = DONE;
            
            else state_next = state_curr;
        end

        else if( state_curr == DONE ) begin
            if( ostream_rdy )
                state_next = IDLE;

            else state_next = state_curr;
        end

        else state_next = state_curr;
    end

    // Define interface outputs based on FSM state

    assign istream_rdy = ( state_curr == IDLE );
    assign ostream_val = ( state_curr == DONE );

    //--------------------Datapath--------------------

    // Calculated the subtracted value our iterative divider uses
    assign subtracted_val = ( opa_reg - opb_reg );

    // opa tracks the value that our final result will be
    always @( posedge clk ) begin
        if( reset ) opa_reg <= 0;

        else if( state_curr == IDLE ) begin
            opa_reg <= opa;
        end

        else if( state_curr == ITR_CALC ) begin
            opa_reg <= subtracted_val;
        end

        else if( state_curr == SHIFT_CALC ) begin
            if( opb_reg <= opa_reg ) begin // Need to subtract
                opa_reg <= ( opa_reg - opb_reg );
            end
        end
    end

    // opb keeps track of our current divisor
    always @( posedge clk ) begin
        if( reset ) opb_reg <= 0;

        else if( state_curr == IDLE ) begin
            opb_reg <= opb;
        end

        else if( state_curr == SHIFT_OPB ) begin
            opb_reg <= opb_reg_sl; // Shift left until the MSB is 1
        end

        else if( state_curr == SHIFT_CALC ) begin
            opb_reg <= ( opb_reg >> 1 ); // Shift right to divide opa
        end
    end

    // Keep track of our initial divisor with opb - we assume this doesn't change
    // mid-division

    // Our output will always be stored in the opa register
    assign result = opa_reg;

endmodule

`endif // SRC_COMBO_DIV