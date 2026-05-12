`timescale 1ns / 1ps
// Produces a pulse width modulated signal where the output is high for
// DUTY_CYCLES every period
// Parameters :
// PERIOD_CYCLES - the number of cycles in a period
// DUTY_CYCLES - then number of cycles the output is high for during each
// period
//
// Ports :
// clk - all flip flops trigger on rising edge
// rst - synchronous reset
// pwm_out - high for DUTY_CYCLE counts each period



module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);
  localparam int CountWidth = (PERIOD_CYCLES > 1) ? $clog2(PERIOD_CYCLES + 1) : 1;
  logic [CountWidth - 1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(CountWidth)
  ) pwm_count (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );


  assign pwm_out = (count < CountWidth'(DUTY_CYCLES));


endmodule
