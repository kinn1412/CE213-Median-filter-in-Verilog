`timescale 1ns/1ps
`default_nettype none

// Convert (pixel,x,y) stream into EXTENDED stream: add 1 dummy pixel after each row, then 1 dummy row.

module stream_extend_from_xy #(
  parameter integer WIDTH  = 430,
  parameter integer HEIGHT = 554,
  parameter [7:0]   DUMMY  = 8'h00
)(
  input  wire        clk,
  input  wire        rst_n,

  input  wire        in_valid,
  input  wire [7:0]  in_pixel,
  input  wire [31:0] in_x,
  input  wire [31:0] in_y,

  output reg         out_valid,
  output reg  [7:0]  out_pixel,

  output reg         done
);

  localparam integer LINE_W = WIDTH + 1;

  reg pending_dummy_col;
  reg pending_dummy_row;
  reg [31:0] dummy_row_cnt;

  reg saw_last_pixel;

  // 1-deep buffer (skid)
  reg        buf_valid;
  reg [7:0]  buf_pixel;
  reg [31:0] buf_x;
  reg [31:0] buf_y;

  wire        src_valid = buf_valid | in_valid;
  wire [7:0]  src_pixel = buf_valid ? buf_pixel : in_pixel;
  wire [31:0] src_x     = buf_valid ? buf_x     : in_x;
  wire [31:0] src_y     = buf_valid ? buf_y     : in_y;
  wire        src_from_buf = buf_valid;

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      out_valid <= 1'b0;
      out_pixel <= DUMMY;
      done      <= 1'b0;

      pending_dummy_col <= 1'b0;
      pending_dummy_row <= 1'b0;
      dummy_row_cnt     <= 0;
      saw_last_pixel    <= 1'b0;

      buf_valid <= 1'b0;
      buf_pixel <= 8'h00;
      buf_x     <= 0;
      buf_y     <= 0;
    end else begin
      out_valid <= 1'b0;
      done      <= 1'b0;

      // Capture live input if we are busy emitting dummy and buffer is empty
      if(in_valid && !buf_valid && (pending_dummy_col || pending_dummy_row)) begin
        buf_valid <= 1'b1;
        buf_pixel <= in_pixel;
        buf_x     <= in_x;
        buf_y     <= in_y;
      end

      // Emit dummy column
      if(pending_dummy_col) begin
        out_valid <= 1'b1;
        out_pixel <= DUMMY;
        pending_dummy_col <= 1'b0;

        if(saw_last_pixel) begin
          pending_dummy_row <= 1'b1;
          dummy_row_cnt     <= 0;
        end
      end
      // Emit dummy row
      else if(pending_dummy_row) begin
        out_valid <= 1'b1;
        out_pixel <= DUMMY;

        if(dummy_row_cnt == (LINE_W-1)) begin
          pending_dummy_row <= 1'b0;
          done <= 1'b1;
        end else begin
          dummy_row_cnt <= dummy_row_cnt + 1;
        end
      end
      // Emit real sample (buffer first)
      else if(src_valid) begin
        out_valid <= 1'b1;
        out_pixel <= src_pixel;

        if(src_from_buf) begin
          buf_valid <= 1'b0;
        end

        if(src_x == (WIDTH-1)) begin
          pending_dummy_col <= 1'b1;
        end

        if((src_x == (WIDTH-1)) && (src_y == (HEIGHT-1))) begin
          saw_last_pixel <= 1'b1;
        end
      end
    end
  end

endmodule

`default_nettype wire
