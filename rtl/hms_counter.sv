`timescale 1ns / 1ps

// Increments time so that when seconds wrap around to 0 the minutes will
// increment and when minutes wrap around to 0 hours will increment
//
// Parameters :
// N_HOURS - default number of hours is 24
// N_MINUTES - defualt number of minutes is 60
// N_SECONDS - default number of seconds is 60
// W_HOURS - width needed to output hours (default is 5 to represent 24)
// W_MINUTES - width needed to output minutes (default is 6 to represent 60)
// W_SECONDS - width needed to output seconds (default is 6 to represent 60)
//
// Ports :
// clk
// enable - when low seconds, minutes and hours stay the same, when high
// increments
// hours - the number of hours that have passed
// minutes - the number of minutes that have passed
// seconds - the number of seconds that have passed



module hms_counter #(
    parameter int N_HOURS   = 24,  // number of hours
    parameter int N_MINUTES = 60,  //number of minutes
    parameter int N_SECONDS = 60,  //number of seconds

    //output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);

  logic second_rollover;
  logic minute_rollover;

  // determines when a second has wrapped (and only occurs when enable is high)
  assign second_rollover = enable && (seconds == MaxSeconds);

  // determines when a minutes has wrapped (and only occurs when the seconds has
  // rolled over)
  assign minute_rollover = second_rollover && (minutes == MaxMinutes);


  // hours increment when minutes rollover
  up_down_counter #(
      .WIDTH(W_HOURS),
      .MAX  (N_HOURS - 1)
  ) u_hour (
      .clk(clk),
      .enable(minute_rollover),
      .up('1),
      .count(hours)
  );

  // minutes increment when seconds rollover
  up_down_counter #(
      .WIDTH(W_MINUTES),
      .MAX  (N_MINUTES - 1)
  ) u_minute (
      .clk(clk),
      .enable(second_rollover),
      .up('1),
      .count(minutes)
  );

  up_down_counter #(
      .WIDTH(W_SECONDS),
      .MAX  (N_SECONDS - 1)
  ) u_second (
      .clk(clk),
      .enable(enable),
      .up('1),
      .count(seconds)
  );

endmodule
