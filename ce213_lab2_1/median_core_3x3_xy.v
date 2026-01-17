`timescale 1ns/1ps
`default_nettype none

// Full-frame 3x3 median filter with replicate padding.
// Input must be the extended stream (WIDTH+1)*(HEIGHT+1).
// Output asserts out_valid exactly WIDTH*HEIGHT times, with out_x/out_y in row-major order.
module median_core_3x3_xy #(
  parameter integer WIDTH  = 430,
  parameter integer HEIGHT = 554
)(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       in_valid,
  input  wire [7:0] pixel_in,

  output reg        out_valid,
  output reg  [7:0] pixel_out,
  output reg [31:0] out_x,
  output reg [31:0] out_y
);

  wire        w_valid;
  wire [31:0] wx, wy;

  wire [7:0] p00,p01,p02,p10,p11,p12,p20,p21,p22;

  window_3x3_stream #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
  ) u_win (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .pixel_in(pixel_in),
    .win_valid(w_valid),
    .out_x(wx),
    .out_y(wy),
    .p00(p00), .p01(p01), .p02(p02),
    .p10(p10), .p11(p11), .p12(p12),
    .p20(p20), .p21(p21), .p22(p22)
  );

  wire [7:0] q00,q01,q02,q10,q11,q12,q20,q21,q22;
  pad_replicate_3x3 #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
  ) u_pad (
    .out_x(wx),
    .out_y(wy),
    .p00(p00), .p01(p01), .p02(p02),
    .p10(p10), .p11(p11), .p12(p12),
    .p20(p20), .p21(p21), .p22(p22),
    .q00(q00), .q01(q01), .q02(q02),
    .q10(q10), .q11(q11), .q12(q12),
    .q20(q20), .q21(q21), .q22(q22)
  );

  wire [7:0] med;
  median9_sortnet u_med (
    .a0(q00), .a1(q01), .a2(q02),
    .a3(q10), .a4(q11), .a5(q12),
    .a6(q20), .a7(q21), .a8(q22),
    .med(med)
  );

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      out_valid <= 1'b0;
      pixel_out <= 8'h00;
      out_x     <= 0;
      out_y     <= 0;
    end else begin
      out_valid <= w_valid;
      if(w_valid) begin
        pixel_out <= med;
        out_x     <= wx;
        out_y     <= wy;
      end else begin
        pixel_out <= 8'h00;
      end
    end
  end

endmodule

`default_nettype wire
