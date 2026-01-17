`timescale 1ns/1ps
`default_nettype none

module median9_sortnet(
  input  wire [7:0] a0,a1,a2,a3,a4,a5,a6,a7,a8,
  output wire [7:0] med
);
  function [7:0] median9_u8;
    input [7:0] b0,b1,b2,b3,b4,b5,b6,b7,b8;
    reg   [7:0] v0,v1,v2,v3,v4,v5,v6,v7,v8;
    reg   [7:0] t;
    begin
      v0=b0; v1=b1; v2=b2; v3=b3; v4=b4; v5=b5; v6=b6; v7=b7; v8=b8;

      if(v0>v1) begin t=v0; v0=v1; v1=t; end
      if(v2>v3) begin t=v2; v2=v3; v3=t; end
      if(v4>v5) begin t=v4; v4=v5; v5=t; end
      if(v6>v7) begin t=v6; v6=v7; v7=t; end

      if(v1>v2) begin t=v1; v1=v2; v2=t; end
      if(v3>v4) begin t=v3; v3=v4; v4=t; end
      if(v5>v6) begin t=v5; v5=v6; v6=t; end
      if(v7>v8) begin t=v7; v7=v8; v8=t; end

      if(v0>v1) begin t=v0; v0=v1; v1=t; end
      if(v2>v3) begin t=v2; v2=v3; v3=t; end
      if(v4>v5) begin t=v4; v4=v5; v5=t; end
      if(v6>v7) begin t=v6; v6=v7; v7=t; end

      if(v1>v2) begin t=v1; v1=v2; v2=t; end
      if(v3>v4) begin t=v3; v3=v4; v4=t; end
      if(v5>v6) begin t=v5; v5=v6; v6=t; end
      if(v7>v8) begin t=v7; v7=v8; v8=t; end

      if(v0>v1) begin t=v0; v0=v1; v1=t; end
      if(v2>v3) begin t=v2; v2=v3; v3=t; end
      if(v4>v5) begin t=v4; v4=v5; v5=t; end
      if(v6>v7) begin t=v6; v6=v7; v7=t; end

      if(v1>v2) begin t=v1; v1=v2; v2=t; end
      if(v3>v4) begin t=v3; v3=v4; v4=t; end
      if(v5>v6) begin t=v5; v5=v6; v6=t; end
      if(v7>v8) begin t=v7; v7=v8; v8=t; end

      if(v0>v1) begin t=v0; v0=v1; v1=t; end
      if(v2>v3) begin t=v2; v2=v3; v3=t; end
      if(v4>v5) begin t=v4; v4=v5; v5=t; end
      if(v6>v7) begin t=v6; v6=v7; v7=t; end

      if(v1>v2) begin t=v1; v1=v2; v2=t; end
      if(v3>v4) begin t=v3; v3=v4; v4=t; end
      if(v5>v6) begin t=v5; v5=v6; v6=t; end
      if(v7>v8) begin t=v7; v7=v8; v8=t; end

      if(v0>v1) begin t=v0; v0=v1; v1=t; end
      if(v2>v3) begin t=v2; v2=v3; v3=t; end
      if(v4>v5) begin t=v4; v4=v5; v5=t; end
      if(v6>v7) begin t=v6; v6=v7; v7=t; end

      median9_u8 = v4;
    end
  endfunction

  assign med = median9_u8(a0,a1,a2,a3,a4,a5,a6,a7,a8);

endmodule

`default_nettype wire
