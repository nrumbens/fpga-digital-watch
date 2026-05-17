`timescale 1ns / 1ps
// Up/down counter with 2 modes. Normal mode increments on every tick pulse.
// In edit mode a high signal of inc increments count and high signal of
// dec decremetns signal.
// Increments count when up is high and deincrements count when up is low
//
// Parameters:
// N -  maximum count number
// WIDTH - number of bits needed to display the maximum number
//
// Ports:
// clk - all flip flops trigger on rising edge
// tick - high pulse increments count
// edit mode - enables edit mode when high
// inc - increments by 1 when in edit mode
// dec - decrements by 1 when in edit mode
// count - outputs the current number


module editable_counter #(
    parameter int N = 60,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic tick,  // Count increments on tick when edit_mode is low
    input logic edit_mode,
    input logic inc,  // Count increments by one when edit_mode is high
    input logic dec,  // Count decrements by one when edit_mode is high
    output logic [WIDTH -1:0] count
);

  logic enable;

  logic up;
  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  // increment when in normal mode or when inc is high in edit mode
  assign up = inc_event || tick_event;
  // counter updates on any valid event
  assign enable = inc_event || tick_event || dec_event;

endmodule
