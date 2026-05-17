`timescale 1ns / 1ps
// When a button has been held for HOLD_CYCLES the button becomes armed and
// allows additional presses of the button to cycle through edit modes (editing
// seconds, minutes, hours). Disarms when the button is pressed again after
// being in hours edit mode.
//
// Parameters :
// HOLD_CYCLES - the number of cycles the button must be held for to become
// armed
//
// Ports :
// clk - all flip flops trigger on rising edge
// button - input signal that enters armed when held and advances edit mode
// in subsequent presses
// mode_enable - output signal indicating the current edit mode


module edit_mode_selector #(
    parameter int HOLD_CYCLES = 50_000_000
) (
    input logic clk,
    input logic button,
    output logic [2:0] mode_enable
);

  logic long_press;
  button_hold_pulse #(
      .HOLD_CYCLES(HOLD_CYCLES)
  ) u_hold_pulse (
      .clk(clk),
      .button(button),
      .pulse(long_press)
  );

  logic press;
  rising_edge_detector u_detector (
      .clk(clk),
      .sig_in(button),
      .rise(press)
  );

  logic armed;
  logic disarm;
  arming_latch u_latch (
      .clk(clk),
      .arm(long_press),
      .disarm(disarm),
      .armed(armed)
  );


  logic reset_counter;
  logic enable_counter;
  logic [1:0] count;
  mod_n_counter #(
      .N(3),
      .WIDTH(2)
  ) u_mod_3_counter (
      .clk(clk),
      .rst(reset_counter),
      .enable(enable_counter),
      .count(count)
  );



  // Counter increments only while armed and button pressed
  assign enable_counter = armed && press;
  // Counter resets when disarmed
  assign reset_counter = !armed;

  // Disarm on the press that steps past the last mode
  assign disarm = press && (count == 2'd2);

  // Output logic
  assign mode_enable = armed ? (3'b001 << count) : 3'b000;

endmodule
