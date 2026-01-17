`timescale 1ns/1ps
`default_nettype none

module max9_u8(
  input  wire [7:0] a0,a1,a2,a3,a4,a5,a6,a7,a8,
  output wire [7:0] mx
);
  function [7:0] max2;
    input [7:0] x,y;
    begin
      max2 = (x > y) ? x : y;
    end
  endfunction

  wire [7:0] m01 = max2(a0,a1);
  wire [7:0] m23 = max2(a2,a3);
  wire [7:0] m45 = max2(a4,a5);
  wire [7:0] m67 = max2(a6,a7);

  wire [7:0] m0123 = max2(m01, m23);
  wire [7:0] m4567 = max2(m45, m67);

  wire [7:0] m0_7 = max2(m0123, m4567);
  assign mx = max2(m0_7, a8);

endmodule

`default_nettype wire
