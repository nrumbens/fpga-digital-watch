`timescale 1ns / 1ps

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);


  logic next_counter_rst;
  logic next_counter_enable;
  logic next_lap_hold;

  logic valid_start;
  logic valid_lap;

  assign valid_start = rise_start_stop && !rise_lap;

  assign valid_lap   = !rise_start_stop && rise_lap;

  initial begin
    counter_rst = 1'b0;
    counter_enable = 1'b0;
    lap_hold = 1'b0;
  end

  always_ff @(posedge clk) begin
    counter_rst <= next_counter_rst;
    counter_enable <= next_counter_enable;
    lap_hold <= next_lap_hold;
  end


  // stopped and live and then lap/reset button pressed (and start/stop not pressed)
  assign next_counter_rst = !counter_enable && !lap_hold && valid_lap;

  // only change enable if a start/stop button pressed and both buttons aren't
  // pressed simultaneously
  assign next_counter_enable = (valid_start) ? !counter_enable : counter_enable;


  always_comb begin
    // to avoid inferred latch
    next_lap_hold = lap_hold;

    // lap/reset button pressed and start/stop isnt simultaneously
    if (valid_lap) begin
      // when counter reset display should stay live
      if (!counter_enable && !lap_hold) next_lap_hold = 1'b0;
      else next_lap_hold = !lap_hold;

    end

  end




endmodule
