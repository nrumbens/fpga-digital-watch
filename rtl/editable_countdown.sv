`timescale 1ns / 1ps
// Counter decrements on every tick pulse and wraps from 0 to MAX. The borrow
// out high when the count has wrapped
//
// Parameters:
// MAX - maximum counter value
// WIDTH - Number of bits needed to store max value
//
// Ports :
// clk - all flip flops trigger on rising edge
// clr - synchronous reset
// tick - decrement pulse on every rising edge of tick
// edit_mode - allows manual editing of counter
// inc - incrment counter in edit mode
// dec - decrement counter in edit mode
// count - current value
// borrow_out - high when counter wraps


module editable_countdown #(
    parameter int MAX   = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH -1:0] count,
    output logic borrow_out
);


  logic enable;
  logic up;
  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(clr),
      .enable(enable),
      .up(up),
      .count(count)
  );

  wire inc_event = edit_mode && inc && !dec;
  wire dec_event = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  // increment when inc is high in edit mode
  assign up = inc_event;
  // counter updates on any valid event
  assign enable = inc_event || tick_event || dec_event;

  // occurs when counter is at 0 and wraps to Max when decrementing (disabled
  // during reset)
  assign borrow_out = (tick_event && (count == 0)) && !clr;

endmodule
