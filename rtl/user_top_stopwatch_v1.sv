// ------------------------------------------------------------------
// WARNING: This file is used by the automated test suite. Do not
// modify it.
//
// This file also serves as a template for your own designs. To use
// it:
//   1. Copy the entire contents into a new file with a descriptive
//      name.
//   2. Delete the test logic below and replace it with your own
//      code.
//   3. In top_de1_soc, change the module name from user_top to your
//      new module name.
//
//   The board wrapper sets CYCLES_PER_SECOND; use this parameter in
//   your design wherever timing is needed.
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  assign led = '0;
  assign blank_hours = 1'b0;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

  logic [6:0] minutes;
  logic [5:0] seconds;
  logic [6:0] centiseconds;




  logic start_pulse;
  logic lap_pulse;

  // rising edge detectors for buttons
  rising_edge_detector u_start (
      .clk(clk),
      .sig_in(button[0]),
      .rise(start_pulse)
  );


  rising_edge_detector u_lap (
      .clk(clk),
      .sig_in(button[1]),
      .rise(lap_pulse)
  );



  logic lap_hold;
  logic counter_rst;
  logic counter_enable;
  stopwatch_control u_control (
      .clk(clk),
      .rise_start_stop(start_pulse),
      .rise_lap(lap_pulse),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );



  // use a mux for each time display
  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_minutes (
      .clk(clk),
      .hold(lap_hold),
      .d(minutes),
      .q(hours_disp)
  );

  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_seconds (
      .clk(clk),
      .hold(lap_hold),
      .d({1'b0, seconds}),
      .q(minutes_disp)
  );


  snapshot_mux #(
      .WIDTH(7)
  ) u_snapshot_centiseconds (
      .clk(clk),
      .hold(lap_hold),
      .d(centiseconds),
      .q(seconds_disp)
  );


  stopwatch_counter #(CYCLES_PER_SECOND) u_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(minutes),
      .seconds(seconds),
      .centiseconds(centiseconds)
  );




endmodule
