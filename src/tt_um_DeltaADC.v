//======================================================
// DeltaADC Top-Level
//======================================================
// Function:
//   - Closes a simple digital loop:
//       Comparator_i -> FSM decides +1 / -1
//       FSM drives next_value and enable (on sampling_strb)
//       ADC_value register stores the value (adc_value_q)
//       adc_value_q feeds PWM.on_counter_val
//   - Strobes (sampling_strb) make updates equidistant in time.
//
// I/O:
//   Inputs : clk, reset, Period_counter_val, Comparator_i
//   Outputs: On_counter_val, ADC_valid_strb, PWM_O
//
// Notes:
//   - sampling_strb is a 1-cycle pulse every STROBE_CYCLES clocks.
//   - enable is asserted exactly on sampling_strb.
//   - next_value is computed by the FSM at each sampling_strb.
//======================================================

`timescale 1ns/1ps

module DeltaADC #(
    parameter integer W             = 16,   // width of ADC/PWM value
    parameter integer STROBE_CYCLES = 16    // interval between samples (adjust as needed)
)(
    input  wire           clk,
    input  wire           reset,                      // active-high reset
    input  wire [W-1:0]   Period_counter_val,         // PWM period in clock cycles
    input  wire           Comparator_i,               // 1 => increase, 0 => decrease
    output wire [W-1:0]   On_counter_val,            // to PWM and (internally) back to FSM
    output wire           ADC_valid_strb,            // pulse when value really updated
    output wire           PWM_O                       // PWM output
);

    //=============================
    // Internal signals (as requested)
    //=============================
    wire           sampling_strb;     // connects StrobeGen -> FSM (and others)
    wire           enable;            // connects FSM -> ADC_value & ADC_valid_strb
    wire [W-1:0]   next_value;        // connects FSM -> ADC_value & ADC_valid_strb
    wire [W-1:0]   adc_value_q;       // registered ADC value (feedback), equals On_counter_val

    //=============================
    // Strobe generator
    //=============================
    StrobeGen #(
        .STROBE_CYCLES(STROBE_CYCLES)
    ) u_stb (
        .clk           (clk),
        .reset         (reset),
        .sampling_strb (sampling_strb)
    );

    //=============================
    // FSM: decides next_value (+1 / -1) on each sampling_strb
    //=============================
    ADC_fsm #(
        .W(W)
    ) u_fsm (
        .clk            (clk),
        .reset          (reset),
        .Comparator_i   (Comparator_i),
        .ADC_value_i    (adc_value_q),     // feedback from register
        .sampling_strb  (sampling_strb),
        .next_value     (next_value),
        .enable         (enable)
    );

    //=============================
    // ADC value register (feeds PWM)
    //=============================
    ADC_value u_adc_val (
        .clk            (clk),
        .reset          (reset),
        .next_value     (next_value),
        .enable         (enable),          // load only on sampling strobes
        .on_counter_val (adc_value_q)
    );

    // Make it visible at the top as required
    assign On_counter_val = adc_value_q;

    //=============================
    // "Value really updated" strobe
    //=============================
    ADC_valid_strb u_valstb (
        .clk            (clk),
        .enable         (enable),          // only check at sampling strobes
        .next_value     (next_value),
        .adc_valid_strb (ADC_valid_strb)
    );

    //=============================
    // PWM: uses the registered value as duty
    //=============================
    PWM u_pwm (
        .clk                (clk),
        .reset              (reset),
        .period_counter_val (Period_counter_val),
        .on_counter_val     (adc_value_q),
        .pwm_o              (PWM_O)
    );

endmodule
