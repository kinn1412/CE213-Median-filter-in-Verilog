`timescale 1ns/1ps
`default_nettype none

// Build a 3x3 window from an "extended" pixel stream.
// Required input stream format:
//   - For each row: WIDTH real pixels (x=0..WIDTH-1) + 1 dummy pixel (x=WIDTH)
//   - After last row: 1 dummy row of (WIDTH+1) pixels
//
// With this format, win_valid will assert exactly WIDTH*HEIGHT times,
// and out_x/out_y are 0..WIDTH-1 / 0..HEIGHT-1.
module window_3x3_stream #(
  parameter integer WIDTH  = 430,
  parameter integer HEIGHT = 554
)(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       in_valid,
  input  wire [7:0] pixel_in,

  output reg        win_valid,
  output reg [31:0] out_x,
  output reg [31:0] out_y,

  output reg  [7:0] p00, p01, p02,
  output reg  [7:0] p10, p11, p12,
  output reg  [7:0] p20, p21, p22
);

  localparam integer LINE_W = WIDTH + 1;

  wire [7:0] d1;
  wire [7:0] d2;

  linebuf2 #(.LINE_W(LINE_W)) u_lb2 (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .din(pixel_in),
    .d1(d1),
    .d2(d2)
  );

  reg [7:0] r2_0, r2_1, r2_2;
  reg [7:0] r1_0, r1_1, r1_2;
  reg [7:0] r0_0, r0_1, r0_2;

  reg [31:0] x;
  reg [31:0] y;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      x <= 0;
      y <= 0;

      r2_0 <= 0; r2_1 <= 0; r2_2 <= 0;
      r1_0 <= 0; r1_1 <= 0; r1_2 <= 0;
      r0_0 <= 0; r0_1 <= 0; r0_2 <= 0;

      win_valid <= 1'b0;
      out_x <= 0;
      out_y <= 0;

      p00 <= 0; p01 <= 0; p02 <= 0;
      p10 <= 0; p11 <= 0; p12 <= 0;
      p20 <= 0; p21 <= 0; p22 <= 0;
    end else if(in_valid) begin
      r2_2 <= r2_1;  r2_1 <= r2_0;  r2_0 <= pixel_in;
      r1_2 <= r1_1;  r1_1 <= r1_0;  r1_0 <= d1;
      r0_2 <= r0_1;  r0_1 <= r0_0;  r0_0 <= d2;

      p00 <= r0_2; p01 <= r0_1; p02 <= r0_0;
      p10 <= r1_2; p11 <= r1_1; p12 <= r1_0;
      p20 <= r2_2; p21 <= r2_1; p22 <= r2_0;

      // output coordinate is (x-1, y-1)
      win_valid <= (x != 0) && (y != 0);
      if((x != 0) && (y != 0)) begin
        out_x <= x - 1;
        out_y <= y - 1;
      end

      // advance extended coords: x=0..WIDTH, y=0..HEIGHT
      if(x == WIDTH) begin
        x <= 0;
        y <= y + 1;
      end else begin
        x <= x + 1;
      end
    end else begin
      win_valid <= 1'b0;
    end
  end

endmodule

`default_nettype wire
