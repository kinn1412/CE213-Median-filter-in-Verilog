`timescale 1ns/1ps
`default_nettype none

module median_filter_3x3 #(
  parameter integer WIDTH  = 430,
  parameter integer HEIGHT = 554
)(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       in_valid,
  input  wire [7:0] pixel_in,
  output wire       out_valid,
  output wire [7:0] pixel_out
);

  // Stage1: median + coordinates (bubbly valid)
  wire        s1_valid;
  wire [7:0]  s1_pixel;
  wire [31:0] s1_x, s1_y;

  median_core_3x3_xy #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
  ) u_med1 (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .pixel_in(pixel_in),
    .out_valid(s1_valid),
    .pixel_out(s1_pixel),
    .out_x(s1_x),
    .out_y(s1_y)
  );

  // Extend using (x,y) (handles bubbles correctly)
  wire       s1e_valid;
  wire [7:0] s1e_pixel;
  wire       s1e_done;

  stream_extend_from_xy #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT),
    .DUMMY(8'h00)
  ) u_ext (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(s1_valid),
    .in_pixel(s1_pixel),
    .in_x(s1_x),
    .in_y(s1_y),
    .out_valid(s1e_valid),
    .out_pixel(s1e_pixel),
    .done(s1e_done)
  );

  // Stage2: conservative border repair
  border_fix_3x3 #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT),
    .STROKE_TH(8'd240),
    .DARK_TH(8'd40),
    .HOLE_TH(8'd120),
    .BR_MIN(4'd3),
    .DK_MIN(4'd2)
  ) u_fix (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(s1e_valid),
    .pixel_in(s1e_pixel),
    .out_valid(out_valid),
    .pixel_out(pixel_out)
  );

endmodule

`default_nettype wire
