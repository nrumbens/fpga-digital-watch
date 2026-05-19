`timescale 1ns / 1ps

// Increments time so that when the first counter rolls over to 0 the second
// counter will increment and when counter1 wraps to 0 counter2 will increment
//
// Parameters :
// N2 - max value for most significant counter
// N1 - max value for middle counter
// N0 - max value for least significant counter
// W0 - width needed to output N0
// W1 - width needed to output N1
// W2 - width needed to output N2
//
// Ports :
// clk - all flip flops trigger on rising edge
// rst - resets all counters to 0
// enable - when counters stay the same, when high increments
// count2 - least signficant count
// count1 - middle count
// count0 - most signficant count

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,

    // Output port widths
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [W2 -1:0] count2,
    output logic [W1 -1:0] count1,
    output logic [W0 -1:0] count0
);

  localparam logic [W0-1:0] Max0 = W0'(N0 - 1);
  localparam logic [W1-1:0] Max1 = W1'(N1 - 1);

  logic rollover0;
  logic rollover1;

  assign rollover0 = enable && (count0 == Max0);
  assign rollover1 = rollover0 && (count1 == Max1);

  mod_n_counter #(
      .N(N0),
      .WIDTH(W0)
  ) u_count0 (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .count(count0)
  );



  mod_n_counter #(
      .N(N1),
      .WIDTH(W1)
  ) u_count1 (
      .clk(clk),
      .rst(rst),
      .enable(rollover0),
      .count(count1)
  );

  mod_n_counter #(
      .N(N2),
      .WIDTH(W2)
  ) u_count2 (
      .clk(clk),
      .rst(rst),
      .enable(rollover1),
      .count(count2)
  );


endmodule
