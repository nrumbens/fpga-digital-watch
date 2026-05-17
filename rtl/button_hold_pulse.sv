`timescale 1ns / 1ps
// Detects when a button has been held for HOLD_CYCLES clock cycles and produces
// a high output signal for a single cycle when the hold time has been reached
//
// Parameters :
// HOLD_CYCLES - the number of cycles the button must be held for
//
// Ports :
// clk - all flip flops trigger on rising edge
// button - input signal
// pulse - output signal that goes high once button has been held for HOLD_CYCLES
// cycles for a single cycle


module button_hold_pulse #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);
  logic held;
  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_detect (
      .clk(clk),
      .button(button),
      .held(held)
  );

  // Detects rising edge of held and produces a single cycle pulse at this
  // rising edge
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(held),
      .rise(pulse)
  );

endmodule
