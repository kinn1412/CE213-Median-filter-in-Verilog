`timescale 1ns/1ps
`default_nettype none

// Extend a WIDTH*HEIGHT pixel stream (row-major) into an "extended" stream:
// - After each row: add 1 dummy pixel (0)
// - After last row: add 1 dummy row of (WIDTH+1) dummy pixels
//
// This is useful when you want to run a second 3x3 window operation after stage1,
// using the same window_3x3_stream module.
module stream_extend_wh #(
  parameter integer WIDTH  = 430,
  parameter integer HEIGHT = 554,
  parameter [7:0]   DUMMY  = 8'h00
)(
  input  wire       clk,
  input  wire       rst_n,

  input  wire       in_valid,
  input  wire [7:0] in_pixel,

  output reg        out_valid,
  output reg  [7:0] out_pixel,

  output reg        done
);

  localparam integer LINE_W = WIDTH + 1;

  reg [31:0] x;
  reg [31:0] y;
  reg [31:0] dx; // dummy-row x

  reg [1:0] state; // 0=PASS,1=DUMMY_COL,2=DUMMY_ROW,3=DONE

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      x <= 0;
      y <= 0;
      dx <= 0;
      state <= 0;
      out_valid <= 1'b0;
      out_pixel <= DUMMY;
      done <= 1'b0;
    end else begin
      out_valid <= 1'b0;
      done <= (state == 3);

      case(state)
        0: begin // PASS real pixels
          if(in_valid) begin
            out_valid <= 1'b1;
            out_pixel <= in_pixel;

            if(x == (WIDTH-1)) begin
              x <= 0;
              state <= 1; // output dummy col next
            end else begin
              x <= x + 1;
            end
          end
        end

        1: begin // DUMMY_COL
          out_valid <= 1'b1;
          out_pixel <= DUMMY;

          if(y == (HEIGHT-1)) begin
            // finished last real row, go to dummy row
            y <= y;     // keep
            dx <= 0;
            state <= 2;
          end else begin
            // next real row
            y <= y + 1;
            state <= 0;
          end
        end

        2: begin // DUMMY_ROW: output LINE_W dummy pixels
          out_valid <= 1'b1;
          out_pixel <= DUMMY;

          if(dx == (LINE_W-1)) begin
            state <= 3;
          end else begin
            dx <= dx + 1;
          end
        end

        default: begin // DONE
          out_valid <= 1'b0;
          out_pixel <= DUMMY;
        end
      endcase
    end
  end

endmodule

`default_nettype wire
