`timescale 1ns / 1ps

// Top-level module integrating debounce, FSM, and 2-digit display
// (generate for-loop unrolled into individual instances)
module top(
    input  wire        clk,
    input  wire        reset_n,
    input  wire [3:0]  moneyin,
    input  wire [3:0]  buy,
    input  wire        refund,
    output wire        buy_fail_led,
    output wire        buy_success_led,
    output wire        moneyin_led,
    output wire        refund_led,
    output wire [3:0]  buy_available_led,
    output wire [7:0]  seg_ext,
    output wire [1:0]  an
);

    // Debounced button signals
    wire [3:0] moneyin_db;
    wire [3:0] buy_db;
    wire       refund_db;

    // Individual debounce instances (unrolled)
    debounce u_db_m0(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (moneyin[0]),
        .out     (moneyin_db[0])
    );
    debounce u_db_b0(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (buy[0]),
        .out     (buy_db[0])
    );

    debounce u_db_m1(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (moneyin[1]),
        .out     (moneyin_db[1])
    );
    debounce u_db_b1(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (buy[1]),
        .out     (buy_db[1])
    );

    debounce u_db_m2(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (moneyin[2]),
        .out     (moneyin_db[2])
    );
    debounce u_db_b2(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (buy[2]),
        .out     (buy_db[2])
    );

    debounce u_db_m3(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (moneyin[3]),
        .out     (moneyin_db[3])
    );
    debounce u_db_b3(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (buy[3]),
        .out     (buy_db[3])
    );

    // Debounce for refund button
    debounce u_db_r(
        .clk     (clk),
        .reset_n (reset_n),
        .in      (refund),
        .out     (refund_db)
    );

    // Wires for raw segment patterns from FSM
    wire [6:0] seg0;
    wire [6:0] seg1;

    // Instantiate vending machine FSM
    vending_machine u_vm (
        .clk               (clk),
        .reset_n           (reset_n),
        .moneyin           (moneyin_db),
        .buy               (buy_db),
        .refund            (refund_db),
        .seg_1000          (seg0),
        .seg_100           (seg1),
        .refund_led        (refund_led),
        .buy_available_led (buy_available_led),
        .moneyin_led       (moneyin_led),
        .buy_success_led   (buy_success_led),
        .buy_fail_led      (buy_fail_led)
    );

    // Instantiate display multiplexer for 2-digit 7-segment
    display_mux u_dm (
        .clk      (clk),
        .reset_n  (reset_n),
        .seg0     (seg0),
        .seg1     (seg1),
        .seg_ext  (seg_ext),
        .an       (an)
    );

endmodule
