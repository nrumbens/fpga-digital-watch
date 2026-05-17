`timescale 1ns / 1ps
// Produces an immediate pulse when button has been pressed and will produce a
// pulse every REPEAT_CYCLES when the button has been held for HOLD_CYCLES
//
// Parameters :
// HOLD_CYCLES - the number of cycles the button must be held for to create a
// pulse train
// REPEAT_CYCLES - the number of cycles between each repeated pulse (when
// creating a pulse train)
//
// Ports :
// clk - all flip flops trigger on rising edge
// button - input signal
// pulse - output signal that goes high immediately and pulses repeatedly when
// the button has been held for HOLD_CYCLES


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


  // make held signal rise early so that that the first pulse occurse at time
  // HOLD_CYCLES not HOLD_CYCLES + REPEAT_CYCLES
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - REPEAT_CYCLES + 1)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  // gives pulse rate (every REPEAT_CYCLES)
  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate_generator (
      .clk (clk),
      .run (held),
      .tick(pulse_train)
  );


endmodule
