`ifndef SRC_ITR_DIV
`define SRC_ITR_DIV

module aidan_mcnay_itr_div #(
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

    // Performs opa/opb with a latency-insensitive interface

    // Define FSM states

    localparam IDLE = 2'd0;
    localparam CALC = 2'd1;
    localparam DONE = 2'd2;

    // Define datapath nets

    reg  [nbits - 1:0] curr_val_reg;
    reg  [nbits - 1:0] subtract_val_reg;
    reg  [nbits - 1:0] curr_val_reg_in;
    wire [nbits - 1:0] subtracted_val;

    //--------------------Control Logic--------------------

    // Define FSM transitions

    reg  [1:0] state_curr;
    reg  [1:0] state_next;

    always @( posedge clk ) begin
        state_curr <= state_next;
    end

    always @( * ) begin
        
        if( reset )
            state_next = IDLE;

        else if( state_curr == IDLE ) begin
            if( istream_val )
                state_next = CALC;
        end

        else if( state_curr == CALC ) begin
            if( subtracted_val < subtract_val_reg )
                state_next = DONE;
        end

        else if( state_curr == DONE ) begin
            if( ostream_rdy )
                state_next = IDLE;
        end

        else state_next = state_curr;
    end

    // Define interface outputs based on FSM state

    assign istream_rdy = ( state_curr == IDLE );
    assign ostream_val = ( state_curr == DONE );

    //--------------------Datapath--------------------

    // For this, we iteratively subtract the subtract_val
    // from the curr_val to get the remainder

    assign subtracted_val = ( curr_val_reg - subtract_val_reg );

    // Determine which value to take based on state

    always @( * ) begin

        if( state_curr == IDLE ) // Take our input value
            curr_val_reg_in = opa;

        else // Take our subtracted value to iterate
            curr_val_reg_in = subtracted_val;
    end

    // Register our values, depending on the state

    always @( posedge clk ) begin
        if( !ostream_val ) // We're in the IDLE or CALC stage - don't change in DONE
            curr_val_reg <= curr_val_reg_in;
    end

    always @( posedge clk ) begin
        if( istream_rdy ) // We're in the IDLE stage - don't change in others
            subtract_val_reg <= opb;
    end

    // Assign the output to be the final remainder
    assign result = curr_val_reg;

endmodule

`endif // SRC_ITR_DIV