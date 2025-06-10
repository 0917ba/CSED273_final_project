`timescale 1ns / 1ps

// Debounce module: filters bouncing button/switch inputs
module debounce(
    input  wire clk,
    input  wire reset_n,
    input  wire in,
    output reg  out
);
    reg [15:0] shift;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            shift <= 16'd0;
            out   <= 1'b0;
        end else begin
            shift <= {shift[14:0], in};
            if (&shift)
                out <= 1'b1;
            else if (~|shift)
                out <= 1'b0;
        end
    end
endmodule