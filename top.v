`timescale 1ns / 1ps

// Structural Top-level module: integrates clock divider, debouncers, D-FF sync registers, pulse generators, FSM, and display mux
module top(
    input  wire        FAST_CLK,            // 100 MHz on-board clock
    input  wire        reset_n,             // active-low reset
    input  wire [3:0]  moneyin,             // coin buttons
    input  wire [3:0]  buy,                 // purchase buttons
    input  wire        refund,              // refund button
    output wire        buy_fail_led,
    output wire        buy_success_led,
    output wire        moneyin_led,
    output wire        refund_led,
    output wire [3:0]  buy_available_led,
    output wire [7:0]  seg_ext,             // {dp,g,f,e,d,c,b,a}
    output wire [1:0]  an                   // common-anode enables
);

    // 1) Slow clock generation (~4 Hz) for FSM domain
    wire SLOW_CLK;
    clk_divider #(
        .DIVISOR(12500000)
    ) u_clkdiv (
        .clk_in  (FAST_CLK),
        .reset_n (reset_n),
        .clk_out (SLOW_CLK)
    );

    // 2) Debounce inputs on FAST_CLK domain
    wire [3:0] moneyin_db_fast;
    wire [3:0] buy_db_fast;
    wire       refund_db_fast;

    debounce u_db_m0 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[0]), .out(moneyin_db_fast[0]));
    debounce u_db_m1 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[1]), .out(moneyin_db_fast[1]));
    debounce u_db_m2 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[2]), .out(moneyin_db_fast[2]));
    debounce u_db_m3 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[3]), .out(moneyin_db_fast[3]));

    debounce u_db_b0 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[0]),      .out(buy_db_fast[0]));
    debounce u_db_b1 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[1]),      .out(buy_db_fast[1]));
    debounce u_db_b2 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[2]),      .out(buy_db_fast[2]));
    debounce u_db_b3 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[3]),      .out(buy_db_fast[3]));

    debounce u_db_r  (.clk(FAST_CLK), .reset_n(reset_n), .in(refund),      .out(refund_db_fast));

    // 3) Synchronize debounced signals into SLOW_CLK domain via D-FFs
    wire [3:0] moneyin_sync;
    wire [3:0] buy_sync;
    wire       refund_sync;

    edge_trigger_D_FF u_dff_m0 (.reset_n(reset_n), .clk(SLOW_CLK), .d(moneyin_db_fast[0]), .q(moneyin_sync[0]), .q_());
    edge_trigger_D_FF u_dff_m1 (.reset_n(reset_n), .clk(SLOW_CLK), .d(moneyin_db_fast[1]), .q(moneyin_sync[1]), .q_());
    edge_trigger_D_FF u_dff_m2 (.reset_n(reset_n), .clk(SLOW_CLK), .d(moneyin_db_fast[2]), .q(moneyin_sync[2]), .q_());
    edge_trigger_D_FF u_dff_m3 (.reset_n(reset_n), .clk(SLOW_CLK), .d(moneyin_db_fast[3]), .q(moneyin_sync[3]), .q_());

    edge_trigger_D_FF u_dff_b0 (.reset_n(reset_n), .clk(SLOW_CLK), .d(buy_db_fast[0]),      .q(buy_sync[0]), .q_());
    edge_trigger_D_FF u_dff_b1 (.reset_n(reset_n), .clk(SLOW_CLK), .d(buy_db_fast[1]),      .q(buy_sync[1]), .q_());
    edge_trigger_D_FF u_dff_b2 (.reset_n(reset_n), .clk(SLOW_CLK), .d(buy_db_fast[2]),      .q(buy_sync[2]), .q_());
    edge_trigger_D_FF u_dff_b3 (.reset_n(reset_n), .clk(SLOW_CLK), .d(buy_db_fast[3]),      .q(buy_sync[3]), .q_());

    edge_trigger_D_FF u_dff_r  (.reset_n(reset_n), .clk(SLOW_CLK), .d(refund_db_fast),    .q(refund_sync),    .q_());

    // 4) Generate pulses for FSM from level-sync signals
    wire [3:0] moneyin_pulse;
    wire [3:0] buy_pulse;

    moneyin_pulse_gen u_mgen (
        .clk     (SLOW_CLK),
        .reset_n (reset_n),
        .in      (moneyin_sync),
        .out     (moneyin_pulse)
    );
    buy_pulse_gen u_bgen (
        .clk     (SLOW_CLK),
        .reset_n (reset_n),
        .in      (buy_sync),
        .out     (buy_pulse)
    );

    // 5) Instantiate FSM vending machine on SLOW_CLK domain
    wire [6:0] seg0;
    wire [6:0] seg1;

    vending_machine u_vm (
        .clk               (SLOW_CLK),
        .reset_n           (reset_n),
        .moneyin           (moneyin_pulse),
        .buy               (buy_pulse),
        .refund            (refund_sync),
        .seg_1000          (seg0),
        .seg_100           (seg1),
        .refund_led        (refund_led),
        .buy_available_led (buy_available_led),
        .moneyin_led       (moneyin_led),
        .buy_success_led   (buy_success_led),
        .buy_fail_led      (buy_fail_led)
    );

    // 6) 2-digit 7-segment multiplexing on FAST_CLK domain
    display_mux u_dm (
        .clk      (FAST_CLK),
        .reset_n  (reset_n),
        .seg0     (seg0),
        .seg1     (seg1),
        .seg_ext  (seg_ext),
        .an       (an)
    );

endmodule
