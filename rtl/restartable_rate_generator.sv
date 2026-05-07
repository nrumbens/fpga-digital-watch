`timescale 1ns / 1ps
// Generates a rising edge every time count reaches the cycle count
//
// Parameters :
// CYCLE_COUNT - the number of cycles that run must remain high before
// outputting a rising edge
//
// Ports :
// clk - all flip flops trigger on rising edge
// run - when low tick is low, when high will increment the count
// tick - high when run is high and has been high for CYCLE_COUNT - 1 cycles

module restartable_rate_generator #(
    parameter int CYCLE_COUNT = 2
) (
    input  logic clk,
    input  logic run,
    output logic tick
);
  logic tick_qualifier;
  logic running = 1'b0;

  always_ff @(posedge clk) running <= run;

  // tick is only valid if still running
  assign tick = running && tick_qualifier;

  generate
    if (CYCLE_COUNT > 1) begin : g_general
      localparam int CountWidth = $clog2(CYCLE_COUNT);

      logic rst_count;
      logic enable_count;
      logic [CountWidth-1:0] count;
      mod_n_counter #(
          .N(CYCLE_COUNT),
          .WIDTH(CountWidth)
      ) u_count (
          .clk(clk),
          .rst(rst_count),
          .enable(enable_count),
          .count(count)
      );

      // resets if run is low or if tick was just high
      assign rst_count = !run || tick_qualifier;

      // counts only increases when run is high
      assign enable_count = run;

      // goes high when counter hits CYCLE_COUNT - 1
      assign tick_qualifier = (count == CountWidth'(CYCLE_COUNT - 1));


    end else begin : g_special
      // if cycle count is 1 tick every cycle
      assign tick_qualifier = 1'b1;
    end
  endgenerate


endmodule
