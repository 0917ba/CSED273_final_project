module display_mux(
  input  wire        clk,
  input  wire        reset_n,
  input  wire [6:0]  seg0,      // 1000자리
  input  wire [6:0]  seg1,      // 100자리
  output reg  [7:0]  seg,       // {dp,g,f,e,d,c,b,a} active-LOW
  output reg  [3:0]  an         // common-anode enables active-LOW
);
  reg [1:0] scan_cnt;
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
      scan_cnt <= 2'd0;
    else
      scan_cnt <= scan_cnt + 2'd1;
  end

  always @(*) begin
    case (scan_cnt)
      2'd0: begin
        an  = 4'b1110;              // digit0 ON (가장 오른쪽)
        seg = {1'b1, seg0};         // seg0 표시
      end
      2'd1: begin
        an  = 4'b1101;              // digit1 ON
        seg = {1'b1, seg1};         // seg1 표시
      end
      2'd2: begin
        an  = 4'b1011;              // digit2 ON
        seg = 8'b1111_1111;         // 모두 OFF (blank)
      end
      2'd3: begin
        an  = 4'b0111;              // digit3 ON
        seg = 8'b1111_1111;         // 모두 OFF (blank)
      end
    endcase
  end
endmodule
