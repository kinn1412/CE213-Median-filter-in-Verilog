`timescale 1ns/1ps
`default_nettype none

// 2-line buffer for streaming images
// d1 = pixel delayed by 1 line (LINE_W samples)
// d2 = pixel delayed by 2 lines (2*LINE_W samples)`timescale 1ns/1ps
`default_nettype none

// 2-line buffer for streaming images
// d1 = pixel delayed by 1 line (LINE_W samples)
// d2 = pixel delayed by 2 lines (2*LINE_W samples)
// LINE_W should match the actual streamed row length.
module linebuf2 #(
  parameter integer LINE_W = 431
)(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       in_valid,
  input  wire [7:0] din,
  output reg  [7:0] d1,
  output reg  [7:0] d2
);

  reg [7:0] mem1 [0:LINE_W-1];
  reg [7:0] mem2 [0:LINE_W-1];
  reg [31:0] wp;

  reg [31:0] sample_cnt;
  reg [7:0]  rd1;
  reg [7:0]  rd2;

  wire have_1line = (sample_cnt >= LINE_W);
  wire have_2line = (sample_cnt >= (2*LINE_W));

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      wp         <= 0;
      sample_cnt <= 0;
      d1         <= 8'h00;
      d2         <= 8'h00;
    end else if(in_valid) begin
      rd1 = mem1[wp];
      rd2 = mem2[wp];

      mem1[wp] <= din;
      mem2[wp] <= rd1;

      d1 <= have_1line ? rd1 : 8'h00;
      d2 <= have_2line ? rd2 : 8'h00;

      wp <= (wp == (LINE_W-1)) ? 0 : (wp + 1);
      sample_cnt <= sample_cnt + 1;
    end
  end

endmodule

`default_nettype wire


// LINE_W should match the actual streamed row length.
module linebuf2 #(
  parameter integer LINE_W = 431
)(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       in_valid,
  input  wire [7:0] din,
  output reg  [7:0] d1,
  output reg  [7:0] d2
);

  reg [7:0] mem1 [0:LINE_W-1];
  reg [7:0] mem2 [0:LINE_W-1];
  reg [31:0] wp;

  reg [31:0] sample_cnt;
  reg [7:0]  rd1;
  reg [7:0]  rd2;

  wire have_1line = (sample_cnt >= LINE_W);
  wire have_2line = (sample_cnt >= (2*LINE_W));

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      wp         <= 0;
      sample_cnt <= 0;
      d1         <= 8'h00;
      d2         <= 8'h00;
    end else if(in_valid) begin
      rd1 = mem1[wp];
      rd2 = mem2[wp];

      mem1[wp] <= din;
      mem2[wp] <= rd1;

      d1 <= have_1line ? rd1 : 8'h00;
      d2 <= have_2line ? rd2 : 8'h00;

      wp <= (wp == (LINE_W-1)) ? 0 : (wp + 1);
      sample_cnt <= sample_cnt + 1;
    end
  end

endmodule

`default_nettype wire
