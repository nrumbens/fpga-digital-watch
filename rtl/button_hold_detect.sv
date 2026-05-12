`timescale 1ns / 1ps
// Detects when a button has been held for HOLD_CYCLES clock cycles and produces
// a high signal output when the hold time has been reached
//
// Parameters :
// HOLD_CYCLES - the number of cycles the button must be held for
//
// Ports :
// clk - all flip flops trigger on rising edge
// button - input signal
// held - output signal that goes high once button has been held for HOLD_CYCLES
// cycles


module button_hold_detect #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic held
);


  localparam int CountMax = HOLD_CYCLES;
  localparam int CountWidth = $clog2(CountMax + 1);
  logic count_rst;
  logic count_enable;
  logic [CountWidth -1:0] count;

  mod_n_counter #(
      .N(CountMax + 1),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk(clk),
      .rst(count_rst),
      .enable(count_enable),
      .count(count)
  );

  // next state logic
  assign count_rst = !button;
  assign count_enable = button && !held;

  // output logic
  assign held = (count == CountWidth'(CountMax));


endmodule
