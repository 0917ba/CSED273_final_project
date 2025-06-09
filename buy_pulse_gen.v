`timescale 1ns / 1ps

module buy_pulse_gen (
    input        clk,
    input        reset_n,
    input  [3:0] buy,
    output [3:0] buy_pulse
);
    // 지연 값과 그 보수를 wire로 선언
    wire [3:0] buy_d;
    wire [3:0] buy_d_n;

    // D-FF 인스턴스 unrolled
    edge_trigger_D_FF dff0 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (buy[0]),
        .q      (buy_d[0]),
        .q_     (buy_d_n[0])
    );
    edge_trigger_D_FF dff1 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (buy[1]),
        .q      (buy_d[1]),
        .q_     (buy_d_n[1])
    );
    edge_trigger_D_FF dff2 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (buy[2]),
        .q      (buy_d[2]),
        .q_     (buy_d_n[2])
    );
    edge_trigger_D_FF dff3 (
        .clk    (clk),
        .reset_n(reset_n),
        .d      (buy[3]),
        .q      (buy_d[3]),
        .q_     (buy_d_n[3])
    );

    // Pulse 생성: rising-edge 검출
    assign buy_pulse = buy & buy_d_n;
endmodule
