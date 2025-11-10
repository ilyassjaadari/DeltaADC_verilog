`timescale 1ns/1ps

module tb_DeltaADC;

    // -------- Parameters --------
    parameter W             = 16;
    parameter STROBE_CYCLES = 64;
    real CLK_PERIOD_NS      = 20.0;     // 50 MHz
    real DT_S               = 20e-9;    // 20 ns
    real RC_TAU_S           = 200e-6;   // 200 us
    real ALPHA;                         // DT/TAU computed at run time

    // -------- Clock & Reset --------
    reg clk   = 1'b0;
    reg reset = 1'b1;
    always #(CLK_PERIOD_NS/2.0) clk = ~clk;  // 50 MHz

    // -------- DUT I/O --------
    reg  [W-1:0] Period_counter_val;
    reg          Comparator_i;
    wire [W-1:0] On_counter_val;
    wire         ADC_valid_strb;
    wire         PWM_O;

    // -------- Instantiate DUT --------
    DeltaADC #(
        .W(W),
        .STROBE_CYCLES(STROBE_CYCLES)
    ) dut (
        .clk                (clk),
        .reset              (reset),
        .Period_counter_val (Period_counter_val),
        .Comparator_i       (Comparator_i),
        .On_counter_val     (On_counter_val),
        .ADC_valid_strb     (ADC_valid_strb),
        .PWM_O              (PWM_O)
    );

    // -------- “Analog” model: PWM -> RC -> Vref --------
    real vref;      // filtered PWM (feedback)
    real vin;       // input “analog” value (0.0..1.0)
    real pwm_level; // 0.0 or 1.0

    // RC update every clock
    always @(posedge clk) begin
        pwm_level = PWM_O ? 1.0 : 0.0;
        vref      = vref + (pwm_level - vref) * ALPHA;

        // ideal comparator
        Comparator_i <= (vin > vref);

        if (ADC_valid_strb)
            $display("%0t ns  vin=%0.3f  vref=%0.3f  code=%0d",
                     $time, vin, vref, On_counter_val);
    end

    // -------- Stimulus (no $sin, no $realtime) --------
    integer k;

    initial begin
        ALPHA = DT_S / RC_TAU_S;

        // VCD
        $dumpfile("deltaadc_tb.vcd");
        $dumpvars(0, tb_DeltaADC);

        // init
        Period_counter_val = 16'd1000; // 50e6/1000 = 50 kHz PWM
        vref = 0.0;
        vin  = 0.2;

        // reset a few cycles
        repeat (10) @(posedge clk);
        reset = 1'b0;

        // hold 0.2 for 2 ms
        repeat (100_000) @(posedge clk); // 100k cycles at 50MHz ≈ 2ms

        // step to 0.8 for 2 ms
        vin = 0.8;
        repeat (100_000) @(posedge clk);

        // triangle-ish ramp: 0.2 -> 0.8 over 2.5 ms, then back
        vin = 0.2;
        for (k = 0; k < 125_000; k = k + 1) begin  // ~2.5 ms
            vin = vin + (0.6 / 125_000.0);
            @(posedge clk);
        end
        for (k = 0; k < 125_000; k = k + 1) begin
            vin = vin - (0.6 / 125_000.0);
            @(posedge clk);
        end

        // finish
        repeat (10_000) @(posedge clk);
        $finish;
    end

endmodule
