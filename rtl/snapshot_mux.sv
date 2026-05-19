`timescale 1ns / 1ps

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

  always_ff @(posedge clk) begin
    if (!hold) begin
      stored <= d;
    end
  end


  // when hold is high show stored value otherwise show current value
  assign q = (hold) ? stored : d;

endmodule
