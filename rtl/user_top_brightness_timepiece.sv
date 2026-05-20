`timescale 1ns / 1ps

module user_top_brightness_timepiece #(
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
  logic app_blank_hours, app_blank_minutes, app_blank_seconds;

  user_top_timepiece_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_app (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(app_blank_hours),
      .blank_minutes(app_blank_minutes),
      .blank_seconds(app_blank_seconds)
  );

  // 1ms period
  localparam int Period = CYCLES_PER_SECOND / 1000;
  localparam int Width = $clog2(Period + 1);
  logic [Width - 1:0] pwm_count;

  mod_n_counter #(
      .N(Period),
      .WIDTH(Width)
  ) u_pwm_counter (
      .clk(clk),
      .rst(1'b0),
      .enable(1'b1),
      .count(pwm_count)
  );


  logic [Width -1:0] duty;
  always_comb begin
    case (sw[9:8])
      2'b00:   duty = Width'(Period / 8);  //12.5%
      2'b01:   duty = Width'(Period / 4);  //25%
      2'b11:   duty = Width'(Period / 2);  //50%
      default: duty = Width'(Period);
    endcase
  end

  logic pwm_blank;
  assign pwm_blank = (pwm_count >= duty);

  assign blank_hours = app_blank_hours || pwm_blank;
  assign blank_minutes = app_blank_minutes || pwm_blank;
  assign blank_seconds = app_blank_seconds || pwm_blank;


endmodule
