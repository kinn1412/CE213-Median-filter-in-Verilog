`timescale 1ns/1ps
`default_nettype none

module pad_replicate_3x3 #(
  parameter integer WIDTH  = 430,
  parameter integer HEIGHT = 554
)(
  input  wire [31:0] out_x,
  input  wire [31:0] out_y,

  input  wire [7:0]  p00, p01, p02,
  input  wire [7:0]  p10, p11, p12,
  input  wire [7:0]  p20, p21, p22,

  output reg  [7:0]  q00, q01, q02,
  output reg  [7:0]  q10, q11, q12,
  output reg  [7:0]  q20, q21, q22
);

  wire edge_left   = (out_x == 0);
  wire edge_right  = (out_x == (WIDTH-1));
  wire edge_top    = (out_y == 0);
  wire edge_bottom = (out_y == (HEIGHT-1));

  always @(*) begin
    q00 = p00; q01 = p01; q02 = p02;
    q10 = p10; q11 = p11; q12 = p12;
    q20 = p20; q21 = p21; q22 = p22;

    if(edge_top) begin
      q00 = q10; q01 = q11; q02 = q12;
    end
    if(edge_bottom) begin
      q20 = q10; q21 = q11; q22 = q12;
    end

    if(edge_left) begin
      q00 = q01;
      q10 = q11;
      q20 = q21;
    end
    if(edge_right) begin
      q02 = q01;
      q12 = q11;
      q22 = q21;
    end
  end

endmodule

`default_nettype wire
