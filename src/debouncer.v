`ifndef SRC_DEBOUNCER
`define SRC_DEBOUNCER

module aidan_mcnay_debouncer (
    input  wire clk,
    input  wire reset,

    input  wire in,
    output wire out
);

    // Debounces an input signal by verifying it's the
    // same across 8 cycles

    wire [7:0] switch_on_value;
    wire [7:0] switch_off_value;
    reg        out_reg;

    assign switch_on_value  = 8'hff;
    assign switch_off_value = 8'h00;
    
    assign out = out_reg;

    reg [7:0] input_history;

    always @( posedge clk ) begin

        if( reset ) begin
            input_history <= switch_off_value;
            out_reg <= 0;
        end

        else begin
            // Shift in input
            input_history <= { input_history[6:0], in };

            if     ( input_history == switch_on_value  ) out_reg <= 1'b1;
            else if( input_history == switch_off_value ) out_reg <= 1'b0;
        end
    end

endmodule

`endif // SRC_DEBOUNCER