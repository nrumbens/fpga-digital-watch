`timescale 1ns / 1ps

// Increments count when up is high and deincrements count when up is low. Added
// reset functionality
//
// Parameters:
// MAX for maximum number counted to (or from), default is 2, can be overriden
// WIDTH number of bits needed to display the maximum number
//
// Ports:
// clk - all flip flops trigger on rising edge
// rst - resets the count to 0
// enable - when high the counter will count up/down on the next rising edge
// otherwise will remain on same number
// up - 1 indicates counting upwards, 0 indicates counting down
// count - outputs the current number

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    input logic up,
    output logic [WIDTH-1:0] count
);
  localparam logic [WIDTH-1:0] Max = WIDTH'(MAX);

  logic [WIDTH-1:0] next_count;
  initial count = '0;

  // next state logic (if up then count up otherwise count down)
  always_comb begin
    if (enable) begin
      if (up) begin
        next_count = (count < Max) ? count + WIDTH'(1) : '0;
      end else begin
        next_count = (count > 0) ? count - WIDTH'(1) : Max;
      end

    end else begin
      next_count = count;
    end

  end

  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;


endmodule
