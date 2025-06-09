`timescale 1ns / 1ps


module buy_pulse_gen (
    input        clk,
    input        reset_n,
    input  [3:0] buy,
    output [3:0] buy_pulse
);
    // 지연 값과 그 보수를 모두 wire로 선언
    wire [3:0] buy_d;
    wire [3:0] buy_d_n;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : GEN_PULSE
            // D-FF 인스턴스: 여기도 모듈 인스턴스일 뿐, 내부에 reg는 우리가 작성하지 않음
            edge_trigger_D_FF dff_inst (
                .clk     (clk),
                .reset_n (reset_n),
                .d       (buy[i]),
                .q       (buy_d[i]),
                .q_      (buy_d_n[i])
            );
        end
    endgenerate
    
    assign buy_pulse = buy & buy_d_n;
endmodule