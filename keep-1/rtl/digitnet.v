// Keep-1: a tiny AI chip that reads 8x8 handwritten digits (0-9).
// Input: 64 pixels (1 = ink), row-major: bit 0 = top-left, bit 63 = bottom-right.
// Output: cls = the digit it thinks it sees. Takes about 660 clock cycles.
module digitnet (
  input         clk, rst_n,
  input         start,          // pulse high 1 clock to begin
  input  [63:0] pix,            // the 8x8 picture
  output reg    busy,
  output reg    done,           // pulses high 1 clock when cls is valid
  output reg [3:0] cls          // answer: 0..9
);
  localparam IDLE = 2'd0, ACC = 2'd1, CMP = 2'd2, FIN = 2'd3;
  reg [1:0] state;
  reg [63:0] img;
  reg [3:0] n;                  // which neuron (digit) is being scored
  reg [5:0] p;                  // which pixel
  reg signed [7:0] acc, best;
  reg [3:0] best_n;

  // Trained weights (3 bits each, signed) - one 192-bit row per digit
  function [191:0] wrow(input [3:0] nn);
    reg [191:0] wv;
    begin
      case (nn)
        4'd0: wv = 192'h0382001c8040006e80045c48045c48017040008200038200;
        4'd1: wv = 192'h209fc00011c01fa3f81f90001c12400027c0001fb800f1c0;
        4'd2: wv = 192'h09104004a4401f74001f7180000d40001e0803904803f040;
        4'd3: wv = 192'h001240048e00057dc0009fc01f1140002d40008048009040;
        4'd4: wv = 192'h038fc01f9fc01ca250049050088e48000200037180030dc0;
        4'd5: wv = 192'h1ff280000fc0000f80000e001f82881ee080038040051280;
        4'd6: wv = 192'h0101c008f2400882b80092801ff0400362380371c00381c0;
        4'd7: wv = 192'h035e001f63c01f8200009240050f80040fb8049040049000;
        4'd8: wv = 192'h00120000fe801c92801f15c01c140001004000f0401c0000;
        4'd9: wv = 192'h000000007dc0047d8004e1f8011478058048008040038000;
        default: wv = 192'd0;
      endcase
      wrow = wv;
    end
  endfunction

  // Trained bias per digit
  function signed [6:0] bias(input [3:0] nn);
    begin
      case (nn)
        4'd0: bias = 7'sd0;
        4'd1: bias = 7'sd0;
        4'd2: bias = 7'sd2;
        4'd3: bias = 7'sd0;
        4'd4: bias = 7'sd3;
        4'd5: bias = 7'sd0;
        4'd6: bias = -7'sd1;
        4'd7: bias = 7'sd3;
        4'd8: bias = -7'sd6;
        4'd9: bias = 7'sd1;
        default: bias = 7'sd0;
      endcase
    end
  endfunction

  wire [191:0] row = wrow(n);
  wire signed [2:0] w3 = row[p*3 +: 3];
  wire signed [7:0] w  = {{5{w3[2]}}, w3};            // sign-extend to 8 bits
  wire signed [6:0] b_cur = bias(n + 4'd1);
  wire signed [7:0] bias_next  = {b_cur[6], b_cur};   // sign-extend to 8 bits
  wire signed [6:0] b_first = bias(4'd0);
  wire signed [7:0] bias_first = {b_first[6], b_first};

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE; busy <= 0; done <= 0; cls <= 0;
      img <= 0; n <= 0; p <= 0; acc <= 0; best <= -8'sd128; best_n <= 0;
    end else begin
      done <= 0;
      case (state)
        IDLE: if (start) begin
          img <= pix; n <= 0; p <= 0; acc <= bias_first;
          best <= -8'sd128; best_n <= 0; busy <= 1; state <= ACC;
        end
        ACC: begin
          if (img[p]) acc <= acc + w;
          if (p == 6'd63) state <= CMP; else p <= p + 1;
        end
        CMP: begin
          if (acc > best) begin best <= acc; best_n <= n; end
          if (n == 4'd9) state <= FIN;
          else begin n <= n + 1; p <= 0; acc <= bias_next; state <= ACC; end
        end
        FIN: begin cls <= best_n; done <= 1; busy <= 0; state <= IDLE; end
      endcase
    end
  end
endmodule
