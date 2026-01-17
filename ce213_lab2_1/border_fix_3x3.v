`timescale 1ns/1ps
`default_nettype none

module border_fix_3x3 #(
  parameter integer WIDTH  = 430,
  parameter integer HEIGHT = 554,

  parameter [7:0] STROKE_TH = 8'd240,  // "very white stroke"
  parameter [7:0] DARK_TH   = 8'd40,   // "dark band/background"
  parameter [7:0] HOLE_TH   = 8'd120,  // center <= HOLE_TH considered a hole/block

  parameter [3:0] BR_MIN    = 4'd3,    // at least BR_MIN very-bright neighbors
  parameter [3:0] DK_MIN    = 4'd2     // at least DK_MIN dark neighbors
)(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       in_valid,
  input  wire [7:0] pixel_in,

  output reg        out_valid,
  output reg  [7:0] pixel_out
);

  wire        w_valid;
  wire [31:0] out_x, out_y;

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
    .out_x(out_x),
    .out_y(out_y),
    .p00(p00), .p01(p01), .p02(p02),
    .p10(p10), .p11(p11), .p12(p12),
    .p20(p20), .p21(p21), .p22(p22)
  );

  wire [7:0] q00,q01,q02,q10,q11,q12,q20,q21,q22;
  pad_replicate_3x3 #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
  ) u_pad (
    .out_x(out_x),
    .out_y(out_y),
    .p00(p00), .p01(p01), .p02(p02),
    .p10(p10), .p11(p11), .p12(p12),
    .p20(p20), .p21(p21), .p22(p22),
    .q00(q00), .q01(q01), .q02(q02),
    .q10(q10), .q11(q11), .q12(q12),
    .q20(q20), .q21(q21), .q22(q22)
  );

  wire [7:0] mx;
  max9_u8 u_mx(
    .a0(q00), .a1(q01), .a2(q02),
    .a3(q10), .a4(q11), .a5(q12),
    .a6(q20), .a7(q21), .a8(q22),
    .mx(mx)
  );

  // Count very-bright and dark neighbors (exclude center)
  wire b00 = (q00 >= STROKE_TH);
  wire b01 = (q01 >= STROKE_TH);
  wire b02 = (q02 >= STROKE_TH);
  wire b10 = (q10 >= STROKE_TH);
  wire b12 = (q12 >= STROKE_TH);
  wire b20 = (q20 >= STROKE_TH);
  wire b21 = (q21 >= STROKE_TH);
  wire b22 = (q22 >= STROKE_TH);

  wire d00 = (q00 <= DARK_TH);
  wire d01 = (q01 <= DARK_TH);
  wire d02 = (q02 <= DARK_TH);
  wire d10 = (q10 <= DARK_TH);
  wire d12 = (q12 <= DARK_TH);
  wire d20 = (q20 <= DARK_TH);
  wire d21 = (q21 <= DARK_TH);
  wire d22 = (q22 <= DARK_TH);

  wire [3:0] bright_cnt =
      {3'b0,b00}+{3'b0,b01}+{3'b0,b02}+{3'b0,b10}+
      {3'b0,b12}+{3'b0,b20}+{3'b0,b21}+{3'b0,b22};

  wire [3:0] dark_cnt =
      {3'b0,d00}+{3'b0,d01}+{3'b0,d02}+{3'b0,d10}+
      {3'b0,d12}+{3'b0,d20}+{3'b0,d21}+{3'b0,d22};

  wire hole_fill =
      (q11 <= HOLE_TH) &&
      (mx  >= STROKE_TH) &&
      (bright_cnt >= BR_MIN) &&
      (dark_cnt   >= DK_MIN);

  wire [7:0] y = hole_fill ? mx : q11;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      out_valid <= 1'b0;
      pixel_out <= 8'h00;
    end else begin
      out_valid <= w_valid;
      pixel_out <= w_valid ? y : 8'h00;
    end
  end

endmodule

`default_nettype wire
