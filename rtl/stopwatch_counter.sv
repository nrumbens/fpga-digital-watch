`timescale 1ns / 1ps
// Counter that increments minutes, seconds and centiseconds. First increment
// occurs one centisecond after enable is high.
//
// Parameters:
// CYCLES_PER_SECOND - input clock frequency
//
// Ports :
// clk - all flip flops trigger on rising edge
// rst - resets all counters to 0
// enable - when counters stay the same, when high increments
// minutes - minutes count (0 - 99)
// seconds - seconds count (0 - 59)
// centiseconds - centiseconds count (0 - 99)


module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic clk,
    input logic rst,  // Takes priority over enable
    input logic enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds  // hundreths of a second
);

  logic tick;

  restartable_rate_generator #(CYCLES_PER_SECOND / 100) rate_centisecond (
      .clk (clk),
      .run (enable && !rst),
      .tick(tick)
  );

  logic count_enable;
  assign count_enable = enable && tick;

  cascade_counter #(
      .N2(100),
      .N1(60),
      .N0(100),
      .W2(7),
      .W1(6),
      .W0(7)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(count_enable),
      .count2(minutes),
      .count1(seconds),
      .count0(centiseconds)
  );


endmodule
