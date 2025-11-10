// src/user_project.v
module user_project (
    input  wire [7:0] ui_in,     // dip-switches / inputs (LSBs)
    output wire [7:0] uo_out,    // direct outputs to TB
    input  wire [7:0] uio_in,    // extra inputs (MSBs)
    output wire [7:0] uio_out,   // unused -> 0
    output wire [7:0] uio_oe,    // disable outputs (tri-state)
    input  wire       ena,       // we map to Comparator_i
    input  wire       clk,
    input  wire       rst_n
);
    // --- Wire-ups to your module -------------------------------------------
    localparam integer W = 16;

    wire             reset_hi      = ~rst_n;                // TB is active-low, your module active-high
    wire [W-1:0]     period_value  = {uio_in, ui_in};       // MSB: uio_in[7:0], LSB: ui_in[7:0]
    wire             comparator_i  = ena;                   // simple mapping; change if you prefer another bit

    wire [W-1:0]     on_counter_val;
    wire             adc_valid_strb;
    wire             pwm_o;

    // --- DUT instantiation --------------------------------------------------
    tt_um_DeltaADC #(
        .W(W),
        .STROBE_CYCLES(16)
    ) dut (
        .clk               (clk),
        .reset             (reset_hi),
        .Period_counter_val(period_value),
        .Comparator_i      (comparator_i),
        .On_counter_val    (on_counter_val),
        .ADC_valid_strb    (adc_valid_strb),
        .PWM_O             (pwm_o)
    );

    // --- Expose a compact status on uo_out ---------------------------------
    assign uo_out[0]   = pwm_o;                 // main PWM out
    assign uo_out[1]   = adc_valid_strb;        // strobe
    assign uo_out[7:2] = on_counter_val[5:0];   // low bits for quick observation in TB

    // --- Tri-state the bidirectional pins (unused here) ---------------------
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00; // 0 = input / high-Z
endmodule
