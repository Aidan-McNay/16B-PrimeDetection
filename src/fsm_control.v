`ifndef SRC_FSM_CONTROL
`define SRC_FSM_CONTROL

module aidan_mcnay_fsm_control #(
    parameter nbits = 16
)(
    input  wire clk,
    input  wire reset,

    // Data input signals
    input  wire             ready,
    input  wire [nbits-1:0] value,
    input  wire [nbits-1:0] counter_value,
    input  wire             div_istream_rdy,
    input  wire             div_ostream_val,
    input  wire [nbits-1:0] div_result,
    input  wire             user_en,

    // Data output signals
    output wire             sipo_en,
    output wire             div_istream_val,
    output wire             div_ostream_rdy,
    output wire             counter_latch,
    output wire             counter_en,
    output wire             done,
    output wire             is_prime
);

    // FSM-based control logic for overall prime detector

    // Define states
    localparam IDLE     = 3'd0;
    localparam DIV_REQ  = 3'd1;
    localparam DIV_RESP = 3'd2;
    localparam INCR_VAL = 3'd3;
    localparam SUCCESS  = 3'd4;
    localparam FAILURE  = 3'd5;

    // Define nbit-wide 2, for use later
    wire [nbits-1:0] nbit_2;
    assign nbit_2 = 2;

    // Define FSM transitions

    reg [2:0] state_curr;
    reg [2:0] state_next;

    wire   waiting; // Waiting for new operation
    assign waiting = ( ( state_curr == IDLE ) | ( state_curr == SUCCESS ) | ( state_curr == FAILURE ) );

    always @( posedge clk ) begin
        state_curr <= state_next;
    end

    always @( * ) begin
        
        if( reset )
            state_next = IDLE;

        else if( waiting ) begin
            if( ready )
                state_next = DIV_REQ;

            else state_next = state_curr;
        end

        else if( state_curr == DIV_REQ ) begin
            if( div_istream_rdy ) // Transaction occurred
                state_next = DIV_RESP;

            else state_next = state_curr;
        end

        else if( state_curr == DIV_RESP ) begin

            if( div_ostream_val ) begin // Response ready

                if( value < nbit_2 ) // Base case
                    state_next = FAILURE;

                else if( counter_value == value )
                    state_next = SUCCESS;
                    // We avoid stopping one step earlier to avoid another subtraction unit

                else if( counter_value == 32'h00010000 ) // Early exit
                    state_next = SUCCESS;

                else if( div_result == 0 ) // Divided cleanly
                    state_next = FAILURE;

                else
                    state_next = INCR_VAL;

            end 
            else state_next = DIV_RESP; // Wait for response
        end

        else if( state_curr == INCR_VAL )
            state_next = DIV_REQ;

        else state_next = state_curr;
    end

    // Define outputs based on FSM state

    assign sipo_en = ( (!user_en) & waiting );
    
    assign div_istream_val = ( state_curr == DIV_REQ  );
    assign div_ostream_rdy = ( state_curr == DIV_RESP );

    assign counter_latch = waiting;
    assign counter_en    = ( state_curr == INCR_VAL );

    assign done = ( ( state_curr == SUCCESS ) | ( state_curr == FAILURE ) );
    assign is_prime = ( state_curr == SUCCESS );

endmodule

`endif // SRC_FSM_CONTROL