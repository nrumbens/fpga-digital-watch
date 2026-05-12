`timescale 1ns / 1ps
// Detects rising edge of an input signal and outputs a high pulse that lasts
// a single clock cycle

// Ports :
// clk - all flip flops trigger on rising edge
// sig_in - input signal
// rise - output signal that is high for 1 clock cycle when sig_in transitions
// from low to high


module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  logic prev;
  logic next_prev;

  always_ff @(posedge clk) begin
    prev <= next_prev;
  end

  // next state logic
  assign next_prev = sig_in;

  // output logic
  assign rise = (!prev && sig_in);


endmodule
