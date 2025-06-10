`timescale 1ns / 1ps

// Clock Divider: generates a slow clock with a 0.25 s period (4 Hz) from a fast input clock
module clk_divider #(
    // Default: 100 MHz / (2 * 4 Hz) = 12.5e6 cycles per toggle
    parameter integer DIVISOR = 12500000
)(
    input  wire clk_in,    // fast input clock (e.g., 100 MHz)
    input  wire reset_n,   // active-low reset
    output reg  clk_out    // slow output clock (~4 Hz)
);
    // Compute counter width
    localparam WIDTH = $clog2(DIVISOR);
    reg [WIDTH-1:0] cnt;

    always @(posedge clk_in or negedge reset_n) begin
        if (!reset_n) begin
            cnt     <= {WIDTH{1'b0}};
            clk_out <= 1'b0;
        end else if (cnt == DIVISOR-1) begin
            cnt     <= {WIDTH{1'b0}};
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1;
        end
    end
endmodule