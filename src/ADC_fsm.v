//======================================================
// ADC Up/Down FSM (Combinatorics + Enable)
//======================================================
// Purpose:
//   - On each sampling strobe, look at Comparator_i:
//       * if 1 -> increase ADC_value by 1
//       * if 0 -> decrease ADC_value by 1
//   - Provide "next_value" and an "enable" pulse so the
//     ADC_value register will load the new value.
//   - Includes simple saturation at 0 and MAX.
//
// Notes:
//   - "enable" goes HIGH exactly when "sampling_strb" is HIGH.
//   - "ADC_value_i" is the current value from outside (feedback).
//   - Reset is ACTIVE-HIGH.
//
// I/O:
//   clk, reset
//   Comparator_i    : 1-bit comparator from analog domain
//   ADC_value_i     : current ADC value (feedback)
//   sampling_strb   : one-clock strobe that defines sample times
//   next_value      : next ADC value to be written
//   enable          : load strobe for the ADC_value register
//======================================================

`timescale 1ns/1ps

module ADC_fsm #(
    parameter integer W = 16  // width of the ADC value
)(
    input  wire           clk,            // clock
    input  wire           reset,          // active-high reset
    input  wire           Comparator_i,   // comparator bit (1=Vin>Vref)
    input  wire [W-1:0]   ADC_value_i,    // current ADC value (feedback)
    input  wire           sampling_strb,  // one-clock sampling strobe
    output reg  [W-1:0]   next_value,     // next value to load
    output reg            enable          // 1 when next_value should be loaded
);

    // Limits for saturation
    localparam [W-1:0] MIN_VAL = {W{1'b0}};
    localparam [W-1:0] MAX_VAL = {W{1'b1}};

    // Optional: simple 2-FF synchronizer for Comparator_i
    // (helps if the comparator is asynchronous to clk)
    reg comp_ff1, comp_ff2;
    always @(posedge clk) begin
        comp_ff1 <= Comparator_i;
        comp_ff2 <= comp_ff1;
    end
    wire comp_sync = comp_ff2;

    // Default outputs
    always @(posedge clk) begin
        if (reset) begin
            next_value <= {W{1'b0}};
            enable     <= 1'b0;
        end else begin
            // "enable" is high only during the sampling strobe
            enable <= sampling_strb;

            if (sampling_strb) begin
                // Decide next value at the sampling instant
                if (comp_sync) begin
                    // Increase by 1, saturate at MAX
                    if (ADC_value_i < MAX_VAL)
                        next_value <= ADC_value_i + {{(W-1){1'b0}}, 1'b1};
                    else
                        next_value <= MAX_VAL;
                end else begin
                    // Decrease by 1, saturate at MIN
                    if (ADC_value_i > MIN_VAL)
                        next_value <= ADC_value_i - {{(W-1){1'b0}}, 1'b1};
                    else
                        next_value <= MIN_VAL;
                end
            end else begin
                // When not sampling, hold last computed next_value
                next_value <= next_value;
            end
        end
    end

endmodule
