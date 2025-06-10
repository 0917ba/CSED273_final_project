`timescale 1ns / 1ps

// 2-digit multiplexing display driver for common-anode 7-segment
module display_mux(
    input  wire       clk,
    input  wire       reset_n,
    input  wire [6:0] seg0,
    input  wire [6:0] seg1,
    output reg  [7:0] seg_ext,  // {dp, g, f, e, d, c, b, a}
    output reg  [1:0] an        // an[0], an[1]
);
    reg sel;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            sel <= 1'b0;
        else
            sel <= ~sel;
    end

    always @* begin
        if (sel) begin
            seg_ext = {1'b1, seg1};  // DP off, display seg1
            an      = 2'b01;          // enable digit 1
        end else begin
            seg_ext = {1'b1, seg0};  // DP off, display seg0
            an      = 2'b10;          // enable digit 0
        end
    end
endmodule