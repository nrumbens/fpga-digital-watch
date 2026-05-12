`timescale 1ns / 1ps
module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    // REPEAT_CYCLES must be smaller than HOLD_CYCLES
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  logic rise;
  logic held;
  logic pulse_train;
  assign pulse = rise | (button & pulse_train);

  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(rise)
  );


  // first repeat pulse should occur at time HOLD_CYCLES so subtract REPEAT_CYCLES
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate_generator (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );


endmodule
