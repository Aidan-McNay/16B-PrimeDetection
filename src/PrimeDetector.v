`ifndef SRC_PRIMEDETECTOR
`define SRC_PRIMEDETECTOR

module aidan_mcnay_PrimeDetector #(
    parameter nbits = 32
)(
    input  wire [7:0] io_in,
    output wire [7:0] io_out
);

    // Brings all the pieces together, including
    // FSM-based control logic

    // Unpack input signals
    wire clk;
    wire reset;
    
    wire SDI;
    wire SCLK;
    wire CS; // Active low
    wire ready;

    wire done;
    wire is_prime;

    assign clk   = io_in[0];
    assign reset = io_in[1];
    assign SDI   = io_in[2];
    assign SCLK  = io_in[3];
    assign CS    = io_in[4];
    assign ready = io_in[5];

    assign io_out[0] = done;
    assign io_out[1] = is_prime;

    //--------------------Datapath--------------------

    // SIPO for data input

    wire             sipo_en;
    wire [nbits-1:0] sipo_data_out;

    aidan_mcnay_sipo #( .nbits(nbits) ) sipo (
        .clk      (SCLK),
        .reset    (reset),
        .en       (sipo_en),
        .data_in  (SDI),
        .data_out (sipo_data_out)
    );

    // Counter

    wire             counter_latch;
    wire             counter_en;
    wire [nbits-1:0] counter_data_out;

    wire [nbits-1:0] nbit_2;
    assign nbit_2 = 2;

    aidan_mcnay_counter #( .nbits(nbits) ) counter (
        .clk       (clk),
        .in_num    (nbit_2), // Value to start with - don't divide by 1 or 0
        .latch_val (counter_latch),
        .en        (counter_en),
        .out_num   (counter_data_out)
    );

    // Iterative Divider

    wire div_istream_val;
    wire div_istream_rdy;

    wire div_ostream_val;
    wire div_ostream_rdy;

    wire [nbits-1:0] div_result;

    aidan_mcnay_itr_div #( .nbits(nbits) ) itr_div (
        .clk         (clk),
        .reset       (reset),

        .opa         (sipo_data_out),
        .opb         (counter_data_out),
        .istream_val (div_istream_val),
        .istream_rdy (div_istream_rdy),

        .result      (div_result),
        .ostream_val (div_ostream_val),
        .ostream_rdy (div_ostream_rdy)
    );

    // Change detector for ready signal

    wire ready_change;

    aidan_mcnay_change_detect change_detect (
        .clk        (clk),
        .in_signal  (ready),
        .out_signal (ready_change)
    );

    //--------------------Control Logic--------------------

    // FSM Control Logic

    aidan_mcnay_fsm_control #( .nbits(nbits) ) fsm (
        .clk   (clk),
        .reset (reset),

        // Data input signals
        .ready           (ready_change),
        .value           (sipo_data_out),
        .counter_value   (counter_data_out),
        .div_istream_rdy (div_istream_rdy),
        .div_ostream_val (div_ostream_val),
        .div_result      (div_result),
        .user_en         (CS),

        // Data output signals
        .sipo_en         (sipo_en),
        .div_istream_val (div_istream_val),
        .div_ostream_rdy (div_ostream_rdy),
        .counter_latch   (counter_latch),
        .counter_en      (counter_en),
        .done            (done),
        .is_prime        (is_prime)
    );

endmodule

`endif // SRC_PRIME_DETECTOR