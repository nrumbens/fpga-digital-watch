`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n,  // active - low , asynchronous
    output logic [3:0] key_sync  // active - high , synchronised
);

  logic [3:0] key_inverted = 4'b0;

  always_ff @(posedge clk) begin
    //invert bits
    key_inverted <= ~key_n;

    // go through second ff to stabilise
    key_sync <= key_inverted;
  end



endmodule
