`timescale 1ns / 1ps
// Moore FSM that controls the state the stopwatch is in (whether it is running,
// or stopped and whether it displays the live or frozen time). The state is
// defined by the variables {counter_rst, counter_enable, lap_hold}
//
// Ports:
// clk - all flip flops trigger on rising edge
// rise_start_stop - single cycle pulse for start/stop button
// rise_lap - single cycle pulse for lap/reset button
// counter_rst - resets counter (after lap has been pressed and already stopped
// and not holding)
// counter_enable - high = running, low = stopped
// lap_hold - high = frozen display, low = live display



module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  // define state with 3 variables
  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;

  initial begin
    counter_rst = 1'b0;
    counter_enable = 1'b0;
    lap_hold = 1'b0;
  end

  // ensure only one button press happens at a time
  logic valid_start;
  logic valid_lap;
  assign valid_start = rise_start_stop && !rise_lap;
  assign valid_lap   = !rise_start_stop && rise_lap;



  always_ff @(posedge clk) begin
    counter_rst <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold <= next_lap_hold;
  end


  // stopped, live and lap/reset button pressed
  assign next_counter_rst = !counter_enable && !lap_hold && valid_lap;

  // only change enable if a start/stop button pressed
  assign next_counter_enable = (valid_start) ? !counter_enable : counter_enable;


  // lap hold next state logic
  always_comb begin
    // to avoid inferred latch
    next_lap_hold = lap_hold;

    if (valid_lap) begin
      // special case: don't freeze output if button is being reset
      if (!counter_enable && !lap_hold) next_lap_hold = 1'b0;

      else next_lap_hold = !lap_hold;

    end

  end




endmodule
