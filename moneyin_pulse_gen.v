`timescale 1ns / 1ps

module moneyin_pulse_gen (
    input        clk,
    input        reset_n,
    input  [3:0] moneyin,
    output [3:0] moneyin_pulse
);
    // Delay registers and their complements
    wire [3:0] moneyin_d;
    wire [3:0] moneyin_d_n;

    // D-FF instances (unrolled)
    edge_trigger_D_FF dff0 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (moneyin[0]),
        .q      (moneyin_d[0]),
        .q_     (moneyin_d_n[0])
    );
    edge_trigger_D_FF dff1 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (moneyin[1]),
        .q      (moneyin_d[1]),
        .q_     (moneyin_d_n[1])
    );
    edge_trigger_D_FF dff2 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (moneyin[2]),
        .q      (moneyin_d[2]),
        .q_     (moneyin_d_n[2])
    );
    edge_trigger_D_FF dff3 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (moneyin[3]),
        .q      (moneyin_d[3]),
        .q_     (moneyin_d_n[3])
    );

    // Generate a one-clock pulse on rising edge
    assign moneyin_pulse = moneyin & moneyin_d_n;
endmodule
