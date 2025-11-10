`default_nettype none
module user_project (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    localparam integer W = 16;

    // TinyTapeout Reset ist low-aktiv; dein Core erwartet high-aktiv:
    wire reset_hi = ~rst_n;

    // Beliebiges Mapping in deinen Core (für CI egal):
    wire [W-1:0] Period_counter_val = {uio_in, ui_in};
    wire Comparator_i = ena;

    // Core-Signale (optional)
    wire [W-1:0] On_counter_val;
    wire         ADC_valid_strb;
    wire         PWM_O;

    // Dein Core
    tt_um_DeltaADC #(
        .W(W),
        .STROBE_CYCLES(16)
    ) dut (
        .clk               (clk),
        .reset             (reset_hi),
        .Period_counter_val(Period_counter_val),
        .Comparator_i      (Comparator_i),
        .On_counter_val    (On_counter_val),
        .ADC_valid_strb    (ADC_valid_strb),
        .PWM_O             (PWM_O)
    );

    // *** WICHTIG für CI: uo_out MUSS ui_in spiegeln ***
    assign uo_out = ui_in;

    // Bidir ungenutzt -> Hi-Z
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;
endmodule

