//======================================================
// ADC_Valid_Strobe
//======================================================
// Purpose:
//   - Generates a one-clock pulse (adc_valid_strb)
//     whenever the ADC value is really updated.
//   - The pulse occurs only if 'enable' is HIGH and
//     'next_value' differs from the previous stored value.
//
// Inputs:
//   clk        - main clock
//   enable     - update signal (1 = ADC value may change)
//   next_value - new ADC value from FSM
//
// Output:
//   adc_valid_strb - 1-cycle HIGH when ADC value updated
//======================================================

`timescale 1ns/1ps

module ADC_valid_strb (
    input  wire        clk,             // clock
    input  wire        enable,          // ADC update signal
    input  wire [15:0] next_value,      // next ADC value
    output reg         adc_valid_strb   // pulse when value updated
);

    // register to hold previous value
    reg [15:0] prev_value;

    always @(posedge clk) begin
        // default: no pulse
        adc_valid_strb <= 1'b0;

        // check if enable is active and value actually changes
        if (enable && (next_value != prev_value)) begin
            adc_valid_strb <= 1'b1;      // one clock pulse
            prev_value     <= next_value; // store new value
        end
        else if (enable) begin
            // if enable=1 but value is same, still update prev
            prev_value <= next_value;
        end
    end

endmodule
