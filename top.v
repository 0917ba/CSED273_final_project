`timescale 1ns / 1ps

module top(
    input  wire        FAST_CLK,            // 100 MHz on-board clock
    input  wire        reset_n,             // active-low reset (BTN_C)
    input  wire [8:0]  sw,                  // SW[0]..SW[7] 사용
    output wire [7:0]  led,                  // LD[0]..LD[7] 사용
    output wire [7:0]  seg,             // {dp,g,f,e,d,c,b,a} (active-LOW)
    output wire [3:0]  an                   // common-anode enables (active-LOW)
);

    // 1) Slow clock for FSM (~4 Hz)
    wire SLOW_CLK;
    clk_divider #(.DIVISOR(12500000)) u_clkdiv (
        .clk_in  (FAST_CLK),
        .reset_n (reset_n),
        .clk_out (SLOW_CLK)
    );
    
    wire scan_clk;
    clk_divider #(.DIVISOR(100000)) u_scandiv (
      .clk_in  (FAST_CLK),
      .reset_n (reset_n),
      .clk_out (scan_clk)
    );

    // 2) 입력 매핑
    wire [3:0] moneyin = sw[3:0];  // SW0=moneyin[0], … SW3=moneyin[3]
    wire [3:0] buy     = sw[7:4];  // SW4=buy[0], … SW7=buy[3]
    wire       refund  = sw[8];     // SW[8] 이상 쓰지 않으면 하드웨어 환불 누름은 별도 구현 필요

    // 3) Debounce (FAST_CLK 도메인)
    wire [3:0] moneyin_db_fast, buy_db_fast;
    wire       refund_db_fast;
    debounce u_db_m0 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[0]), .out(moneyin_db_fast[0]));
    debounce u_db_m1 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[1]), .out(moneyin_db_fast[1]));
    debounce u_db_m2 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[2]), .out(moneyin_db_fast[2]));
    debounce u_db_m3 (.clk(FAST_CLK), .reset_n(reset_n), .in(moneyin[3]), .out(moneyin_db_fast[3]));
    debounce u_db_b0 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[0]),     .out(buy_db_fast[0]));
    debounce u_db_b1 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[1]),     .out(buy_db_fast[1]));
    debounce u_db_b2 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[2]),     .out(buy_db_fast[2]));
    debounce u_db_b3 (.clk(FAST_CLK), .reset_n(reset_n), .in(buy[3]),     .out(buy_db_fast[3]));
    // 만약 refund 스위치 사용 시:
    debounce u_db_r (.clk(FAST_CLK), .reset_n(reset_n), .in(refund), .out(refund_db_fast));

    // 4) Synchronize to SLOW_CLK domain
    wire [3:0] moneyin_sync, buy_sync;
    wire       refund_sync;
    edge_trigger_D_FF u_m0 (.clk(SLOW_CLK), .reset_n(reset_n), .d(moneyin_db_fast[0]), .q(moneyin_sync[0]), .q_());
    edge_trigger_D_FF u_m1 (.clk(SLOW_CLK), .reset_n(reset_n), .d(moneyin_db_fast[1]), .q(moneyin_sync[1]), .q_());
    edge_trigger_D_FF u_m2 (.clk(SLOW_CLK), .reset_n(reset_n), .d(moneyin_db_fast[2]), .q(moneyin_sync[2]), .q_());
    edge_trigger_D_FF u_m3 (.clk(SLOW_CLK), .reset_n(reset_n), .d(moneyin_db_fast[3]), .q(moneyin_sync[3]), .q_());
    edge_trigger_D_FF u_b0 (.clk(SLOW_CLK), .reset_n(reset_n), .d(buy_db_fast[0]),     .q(buy_sync[0]),    .q_());
    edge_trigger_D_FF u_b1 (.clk(SLOW_CLK), .reset_n(reset_n), .d(buy_db_fast[1]),     .q(buy_sync[1]),    .q_());
    edge_trigger_D_FF u_b2 (.clk(SLOW_CLK), .reset_n(reset_n), .d(buy_db_fast[2]),     .q(buy_sync[2]),    .q_());
    edge_trigger_D_FF u_b3 (.clk(SLOW_CLK), .reset_n(reset_n), .d(buy_db_fast[3]),     .q(buy_sync[3]),    .q_());
    edge_trigger_D_FF u_r (.clk(SLOW_CLK), .reset_n(reset_n), .d(refund_db_fast), .q(refund_sync), .q_());

    // 5) Pulse generation
    wire [3:0] moneyin_pulse, buy_pulse;
    moneyin_pulse_gen u_mpg (
        .clk            (SLOW_CLK),
        .reset_n        (reset_n),
        .moneyin        (moneyin_sync),
        .moneyin_pulse  (moneyin_pulse)
    );
    buy_pulse_gen u_bpg (
        .clk       (SLOW_CLK),
        .reset_n   (reset_n),
        .buy       (buy_sync),
        .buy_pulse (buy_pulse)
    );

    // 6) FSM vending machine
    wire [6:0] seg0, seg1;
    vending_machine u_vm (
        .clk               (SLOW_CLK),
        .reset_n           (reset_n),
        .moneyin           (moneyin_pulse),
        .buy               (buy_pulse),
        .refund            (refund_sync),
        .seg_1000          (seg0),
        .seg_100           (seg1),
        .refund_led        (led[4]),
        .buy_available_led (led[3:0]),
        .moneyin_led       (led[5]),
        .buy_success_led   (led[6]),
        .buy_fail_led      (led[7])
    );

    // 7) Display mux
    display_mux u_dm (
      .clk     (scan_clk),
      .reset_n (reset_n),
      .seg0    (seg0),
      .seg1    (seg1),
      .seg_ext (seg),
      .an      (an)
    );

endmodule
