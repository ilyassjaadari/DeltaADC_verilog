//======================================================
// PWM Module
//======================================================
// This module generates a PWM (Pulse Width Modulation) signal.
// The signal is high for "on_counter_val" clock cycles
// and low for the rest of the period.
//
// Inputs:
//   clk                - main clock
//   reset              - active high reset, restarts counter
//   period_counter_val - total number of clock cycles in one PWM period
//   on_counter_val     - number of cycles the output stays high
//
// Output:
//   pwm_o              - PWM output signal
//======================================================

module PWM (
    input  wire clk,
    input  wire reset,
    input  wire [15:0] period_counter_val, // total period
    input  wire [15:0] on_counter_val,     // ON duration
    output reg  pwm_o                      // PWM output
);

    // counter counts clock cycles in each period
    reg [15:0] counter;

    always @(posedge clk) begin
        if (reset) begin
            // When reset is active, restart everything
            counter <= 16'd0;
            pwm_o   <= 1'b0;
        end else begin
            // If counter reached the end of the period, restart
            if (counter >= period_counter_val - 1)
                counter <= 16'd0;
            else
                counter <= counter + 1'b1;

            // PWM output is high for "on_counter_val" counts
            if (counter < on_counter_val)
                pwm_o <= 1'b1;
            else
                pwm_o <= 1'b0;
        end
    end

endmodule
