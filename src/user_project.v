// TinyTapeout wrapper around your core tt_um_DeltaADC
`default_nettype none
module user_project (
    input  wire [7:0] ui_in,     // dedicated inputs
    output wire [7:0] uo_out,    // dedicated outputs
    input  wire [7:0] uio_in,    // bidir inputs
    output wire [7:0] uio_out,   // bidir outputs (unused here)
    output wire [7:0] uio_oe,    // bidir output enables (1=drive, 0=hi-Z)
    input  wire       ena,       // design enable
    input  wire       clk,       // system clock
    input  wire       rst_n      // active-low reset from TT
);
    // ---- Parameter match ---------------------------------------------------
    localparam integer W = 16;

    // ---- Map TT pins to your core's ports ---------------------------------
    wire              reset_hi          = ~rst_n;               // TT reset is active-low; your core wants active-high
    wire [W-1:0]      Period_counter_val = {uio_in, ui_in};     // MSB= uio_in[7:0], LSB= ui_in[7:0]
    wire              Comparator_i      = ena;                  // simple mapping; change if you prefer a switch bit

    wire [W-1:0]      On_counter_val;
    wire              ADC_valid_strb;
    wire              PWM_O;

    // ---- Core instantiation ------------------------------------------------
    tt_um_DeltaADC #(
        .W(W),
        .STROBE_CYCLES(16)   // keep your default, adjust if needed
    ) dut (
        .clk               (clk),
        .reset             (reset_hi),
        .Period_counter_val(Period_counter_val),
        .Comparator_i      (Comparator_i),
        .On_counter_val    (On_counter_val),
        .ADC_valid_strb    (ADC_valid_strb),
        .PWM_O             (PWM_O)
    );

    // ---- Drive TT outputs --------------------------------------------------
    assign uo_out[0]   = PWM_O;                 // primary observable output
    assign uo_out[1]   = ADC_valid_strb;        // strobe when value updated
    assign uo_out[7:2] = On_counter_val[5:0];   // expose low bits for quick view

    // ---- Bidir lines unused -> tri-state -----------------------------------
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00; // 0 = input/high-Z

endmodule
