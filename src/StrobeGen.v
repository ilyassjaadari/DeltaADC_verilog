//======================================================
// Strobe Generator (sampling_strb)
//======================================================
// - Generates a single-clock pulse "sampling_strb" at a fixed interval.
// - Interval is set by the parameter STROBE_CYCLES (in clock cycles).
// - Reset is ACTIVE-HIGH and restarts the counter to zero.
//
// Usage examples:
//   * For simulation:  STROBE_CYCLES = 16   (pulse every 16 clocks)
//   * For real use:    STROBE_CYCLES = 5000 (pulse every 5000 clocks)
//======================================================

`timescale 1ns/1ps

module StrobeGen #(
    parameter integer STROBE_CYCLES = 16  // interval between strobes in clock cycles
)(
    input  wire clk,            // clock
    input  wire reset,          // active-high reset
    output reg  sampling_strb   // 1-cycle sampling strobe
);

    // Counter counts up to STROBE_CYCLES-1, then wraps to 0
    reg [31:0] counter;         // 32-bit for safety (works up to large intervals)

    always @(posedge clk) begin
        if (reset) begin
            counter       <= 32'd0;   // restart counting
            sampling_strb <= 1'b0;    // no strobe during reset
        end else begin
            // Default: no strobe
            sampling_strb <= 1'b0;

            // If we reached the target, emit a 1-cycle strobe and wrap
            if (counter >= (STROBE_CYCLES - 1)) begin
                counter       <= 32'd0;
                sampling_strb <= 1'b1;    // pulse for this clock
            end else begin
                counter <= counter + 32'd1;
            end
        end
    end

endmodule
