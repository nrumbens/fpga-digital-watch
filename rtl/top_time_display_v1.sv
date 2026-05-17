`timescale 1ns / 1ps

// Module for time display on DEI-SOC board. The seconds will increase everytime
// tick is high (which is determined by 2 switches) and each seven segment display
// will rollover once they have reached their maximum value and increment the
// next higher counting unit
//
// Parameters :
// CYCLES_PER_SECOND - input clock frequency (50MHz as default)
//
// Ports :
// CLOCK_50 - 50MHz clock, syncs all flip flops (to have same rising edges)
// SW - speed selector (1Hz, 25Hz, 1kHz, 50MHz)
// HEX(0-5) - seven segment display


module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  logic tick, tick_1Hz, tick_25Hz, tick_1kHz, tick_50MHz;
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;
  logic [3:0] hours_tens, hours_ones;
  logic [3:0] minutes_tens, minutes_ones;
  logic [3:0] seconds_tens, seconds_ones;

  hms_counter time_count (
      .clk(CLOCK_50),
      .enable(tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // selects tick rate based on the switch inputs
  always_comb begin
    case (SW)
      2'b00:   tick = tick_1Hz;
      2'b01:   tick = tick_25Hz;
      2'b10:   tick = tick_1kHz;
      2'b11:   tick = tick_50MHz;
      default: tick = tick_50MHz;
    endcase
  end

  // ticks every clock cycle so always high
  assign tick_50MHz = 1'b1;

  // creates tick pulses at 1Hz frequency (from 50MHz source)
  restartable_rate_generator #(CYCLES_PER_SECOND) rate_1Hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1Hz)
  );

  // creates tick pulses at 25Hz frequency (from 50MHz source)
  restartable_rate_generator #(CYCLES_PER_SECOND / 25) rate_25Hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25Hz)
  );

  // creates tick pulses at 1kHz frequency (from 50MHz source)
  restartable_rate_generator #(CYCLES_PER_SECOND / 1000) rate_1kHz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1kHz)
  );


  // converts 5 bit binary hours to two 4 bit ones and tens digits
  binary_to_bcd hours_bcd (
      .bin ({2'b0, hours}),
      .tens(hours_tens),
      .ones(hours_ones)
  );

  // converts 6 bit binary minutes to two 4 bit ones and tens digits
  binary_to_bcd minutes_bcd (
      .bin ({1'b0, minutes}),
      .tens(minutes_tens),
      .ones(minutes_ones)
  );

  // converts 6 bit binary seconds to two 4 bit ones and tens digits
  binary_to_bcd seconds_bcd (
      .bin ({1'b0, seconds}),
      .tens(seconds_tens),
      .ones(seconds_ones)
  );




  // maps digits into seven segment displays
  seven_segment second_ones_digit (
      .digit(seconds_ones),
      .blank(1'b0),
      .segments(HEX0)
  );

  seven_segment second_tens_digit (
      .digit(seconds_tens),
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment minutes_ones_digit (
      .digit(minutes_ones),
      .blank(1'b0),
      .segments(HEX2)
  );

  seven_segment minutes_tens_digit (
      .digit(minutes_tens),
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment hours_ones_digit (
      .digit(hours_ones),
      .blank(1'b0),
      .segments(HEX4)
  );

  seven_segment hours_tens_digit (
      .digit(hours_tens),
      .blank(1'b0),
      .segments(HEX5)
  );



endmodule
