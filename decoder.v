`timescale 1ns / 1ps


module decoder(
    input [3:0] hex,
    output reg [6:0] seg
    );
     
    // activate on any input change
    always @*
    begin
        case(hex)
            4'h0: seg[6:0] = 7'b1000000;    // digit 0
            4'h1: seg[6:0] = 7'b1111001;    // digit 1
            4'h2: seg[6:0] = 7'b0100100;    // digit 2
            4'h3: seg[6:0] = 7'b0110000;    // digit 3
            4'h4: seg[6:0] = 7'b0011001;    // digit 4
            4'h5: seg[6:0] = 7'b0010010;    // digit 5
            4'h6: seg[6:0] = 7'b0000010;    // digit 6
            4'h7: seg[6:0] = 7'b1111000;    // digit 7
            4'h8: seg[6:0] = 7'b0000000;    // digit 8
            4'h9: seg[6:0] = 7'b0010000;    // digit 9
            default: seg[6:0] = 7'b1000000; //default : digit 0
        endcase
    end
endmodule
