`timescale 1ns / 1ps
// On every rising edge of the clock if disarm inputs a high pulse then armed
// will output low until a high pulse of armed occurs (where the output will
// remain high until a pulse of disarm)
//
// Ports :
// clk - all flip flops trigger on rising edge
// arm - input signal that when high (and disarmed is not high) the armed output
// will transition to high
// disarm - input signal that when high will produce a low output signal
// armed - output signal


module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);

  initial armed = 1'b0;

  // synchronous transition
  always_ff @(posedge clk) begin
    if (disarm) armed <= 1'b0;
    else if (arm) armed <= 1'b1;
  end


endmodule
