`timescale 1ns/1ps
`default_nettype none

module tb_median_filter_fileio;

  parameter integer WIDTH   = 430;
  parameter integer HEIGHT  = 554;
  localparam integer NPIX   = WIDTH*HEIGHT;

  reg clk;
  reg rst_n;

  reg        in_valid;
  reg  [7:0] pixel_in;

  wire       out_valid;
  wire [7:0] pixel_out;

  reg [7:0] mem_in  [0:NPIX-1];
  reg [7:0] mem_out [0:NPIX-1];

  integer in_x, in_y;     // extended coords: x=0..WIDTH, y=0..HEIGHT
  integer out_idx;
  integer idx;

  reg done;

  median_filter_3x3 #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .pixel_in(pixel_in),
    .out_valid(out_valid),
    .pixel_out(pixel_out)
  );

  always #5 clk = ~clk;

  // TB drives extended stream: (WIDTH+1)*(HEIGHT+1)
  always @(*) begin
    if(in_valid) begin
      if((in_y < HEIGHT) && (in_x < WIDTH)) begin
        idx = in_y*WIDTH + in_x;
        pixel_in = mem_in[idx];
      end else begin
        pixel_in = 8'h00; // dummy col/row
      end
    end else begin
      pixel_in = 8'h00;
    end
  end

  initial begin
    clk = 1'b0;
    rst_n = 1'b0;

    in_valid = 1'b0;
    in_x = 0;
    in_y = 0;

    out_idx = 0;
    done = 1'b0;

    $readmemh("pic_input.txt", mem_in);

    #20;
    rst_n = 1'b1;
    #10;
    in_valid = 1'b1;
  end

  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      in_x <= 0;
      in_y <= 0;
      in_valid <= 1'b0;
    end else if(in_valid) begin
      if(in_x == WIDTH) begin
        in_x <= 0;
        if(in_y == HEIGHT) begin
          in_valid <= 1'b0;
        end else begin
          in_y <= in_y + 1;
        end
      end else begin
        in_x <= in_x + 1;
      end
    end
  end

  // Capture output (no $finish)
  always @(negedge clk or negedge rst_n) begin
    if(!rst_n) begin
      out_idx <= 0;
      done <= 1'b0;
    end else if(out_valid && !done) begin
      mem_out[out_idx] <= pixel_out;

      if(out_idx == (NPIX-1)) begin
        $writememh("pic_output.txt", mem_out);
        $display("DONE: wrote pic_output.txt (%0d pixels). Stop simulation manually (no $finish).", NPIX);
        done <= 1'b1;
      end

      out_idx <= out_idx + 1;
    end
  end

endmodule

`default_nettype wire
