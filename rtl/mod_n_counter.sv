`timescale 1ns / 1ps
// counts from 0 to N - 1 when enable is high
//
// Parameters :
// N - determines the maximum number counted to (maximum number will be N - 1)
// WIDTH - the number of bits needed to display the maximum number counted to
//
// Ports :
// clk - all flip flops trigger on rising edge
// rst - resets count
// enable - if low count stays the same, if high count advances
// count - outputs the current number

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH - 1:0] count
);

  localparam logic [WIDTH-1:0] Max = WIDTH'(N);
  initial count = '0;
  logic [WIDTH - 1:0] next_count;

  //reset has priority over enable
  always_ff @(posedge clk)
    if (rst) count <= '0;
    else if (enable) count <= next_count;

  // if the maximum value has been reached wrap around
  always_comb begin
    next_count = (count < Max - WIDTH'(1)) ? count + WIDTH'(1) : '0;
  end

endmodule
