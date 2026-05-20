`timescale 1ns / 1ps

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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


  logic borrow_sec, borrow_min;

  logic seconds_edit, seconds_inc, seconds_dec;
  logic minutes_edit, minutes_inc, minutes_dec;
  logic hours_edit, hours_inc, hours_dec;


  // button risinge edges (for pause/start)
  logic start_stop_pulse;
  rising_edge_detector u_button0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(start_stop_pulse)
  );


  // Edit mode selecting
  logic [2:0] mode_enable;

  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk(clk),
      .button(button[3] && !running),
      .mode_enable(mode_enable)
  );



  // 1 Hz tick from system clock
  logic tick1Hz;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_1_Hz (
      .clk(clk),

      // keeps timer at 0 unless time is running
      .run (running),
      .tick(tick1Hz)
  );




  // button auto repeat
  logic inc_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_increment (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  logic dec_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_decrement (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );



  logic [5:0] seconds;
  logic [5:0] minutes;
  logic [4:0] hours;
  //hours

  logic unused_borrow;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .clr(1'b0),
      .tick(borrow_min),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(unused_borrow)
  );

  // minutes
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .clr(1'b0),
      .tick(borrow_sec),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(borrow_min)
  );

  // seconds
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .clr(1'b0),
      .tick(tick1Hz && running),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(borrow_sec)
  );



  // FSM (state is a single bit for running)
  wire at_zero = (hours == 0) && (minutes == 0) && (seconds == 0);
  logic running = 1'b0, next_running;

  always_ff @(posedge clk)
    if (at_zero || mode_enable != 0) running <= 1'b0;
    else running <= next_running;

  assign next_running = start_stop_pulse ? !running : running;




  // only edit when in seconds edit mode
  assign seconds_edit = mode_enable[0];
  assign seconds_inc = mode_enable[0] && inc_pulse;
  assign seconds_dec = mode_enable[0] && dec_pulse;


  assign minutes_edit = mode_enable[1];
  assign minutes_inc = mode_enable[1] && inc_pulse;
  assign minutes_dec = mode_enable[1] && dec_pulse;


  assign hours_edit = mode_enable[2];
  assign hours_inc = mode_enable[2] && inc_pulse;
  assign hours_dec = mode_enable[2] && dec_pulse;



  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)
  ) u_pwm_generator (
      .clk(clk),
      .rst(1'b0),
      .pwm_out(pwm_out)
  );

  assign blank_hours = mode_enable[2] && pwm_out;
  assign blank_minutes = mode_enable[1] && pwm_out;
  assign blank_seconds = mode_enable[0] && pwm_out;





  // Zero - extend counter values to display outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Unused
  assign led = 10'b0;



`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif
endmodule
