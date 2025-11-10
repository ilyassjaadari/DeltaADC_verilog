//======================================================
// ADC_Value Register Block
//======================================================
// Purpose:
//   - Stores the current ADC value.
//   - Updates (loads "next_value") only when 'enable' is HIGH.
//   - Output 'on_counter_val' goes to the PWM module.
//
// Inputs:
//   clk        - main clock
//   reset      - active-high reset
//   next_value - new ADC value from FSM
//   enable     - load signal (1 = update, 0 = hold)
//
// Output:
//   on_counter_val - current ADC value (to PWM)
//======================================================

`timescale 1ns/1ps

module ADC_value (
    input  wire        clk,            // clock
    input  wire        reset,          // active-high reset
    input  wire [15:0] next_value,     // new value from FSM
    input  wire        enable,         // when 1, load new value
    output reg  [15:0] on_counter_val  // current ADC value to PWM
);

    always @(posedge clk) begin
        if (reset) begin
            // reset ADC value to zero
            on_counter_val <= 16'd0;
        end else if (enable) begin
            // when enabled, load the next ADC value
            on_counter_val <= next_value;
        end else begin
            // otherwise, hold the previous value
            on_counter_val <= on_counter_val;
        end
    end

endmodule
