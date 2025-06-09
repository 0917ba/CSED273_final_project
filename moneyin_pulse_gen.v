`timescale 1ns / 1ps

// ==================================================
// 1) moneyin_pulse_gen: 4-bit rising-edge detector
// ==================================================
module moneyin_pulse_gen (
    input        clk,
    input        reset_n,
    input  [3:0] moneyin,
    output [3:0] moneyin_pulse
);
    wire [3:0] moneyin_d;
    wire [3:0] moneyin_d_n;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : GEN_MONEYIN
            edge_trigger_D_FF dff_mi (
                .clk    (clk),
                .reset_n(reset_n),
                .d      (moneyin[i]),
                .q      (moneyin_d[i]),
                .q_     (moneyin_d_n[i])
            );
        end
    endgenerate
    assign moneyin_pulse = moneyin & moneyin_d_n;
endmodule