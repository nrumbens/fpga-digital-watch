`timescale 1ns / 1ps
// Stores most recent input value when hold is low. When hold is high the output
// is the same as the input of the last rising edge before hold went high
//
// Parameters:
// WIDTH - number of bits needed for the input, output and stored values
//
// Ports :
// clk - all flip flops trigger on rising edge
// hold - when high, freezes output
// d - current input value
// q - current output value (either live or stored value)

module snapshot_mux #(
    parameter int WIDTH = 1
) (
    input logic clk,
    input logic hold,
    input logic [WIDTH -1:0] d,
    output logic [WIDTH -1:0] q
);

  logic [WIDTH - 1:0] stored;
  initial stored = '0;

  // save the stored value
  always_ff @(posedge clk) begin
    if (!hold) begin
      stored <= d;
    end
  end


  // when hold is high show stored value otherwise show current value
  assign q = (hold) ? stored : d;

endmodule
