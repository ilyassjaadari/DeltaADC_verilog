<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The DeltaADC implements a simple digital delta modulator, a first-order analog-to-digital conversion loop built entirely in digital logic. It mimics the behavior of a delta-sigma ADC using a feedback system composed of a comparator, a finite state machine (FSM), and a PWM output.

Each sampling cycle, the comparator indicates whether the analog input (or feedback) is above or below a threshold. Based on this 1-bit decision, the FSM adjusts a digital value up or down by one least significant bit (Δ = ±1). This value represents the estimated analog signal and also drives a PWM generator to produce a feedback voltage (if used with an RC filter externally).

## How to test

Clock and Reset

Provide a system clock (clk) up to ~50 MHz (Tiny Tapeout default).

Use an active-high reset signal to initialize the circuit.

Input Signals (ui[7:0])

ui[0]: Comparator input

Logic 1 → input voltage is higher than feedback

Logic 0 → input voltage is lower than feedback

ui[7:1]: PWM period control (sets the PWM frequency)

Larger values → longer period → slower PWM

Smaller values → shorter period → faster PWM

Output Signals (uo[7:0])

uo[0]: PWM_O — main PWM output

uo[1–6]: ADC value bits (for observation/debug)

uo[7]: ADC_valid_strb — pulses each time the ADC updates

Optional External Connection (for demonstration)

Filter the PWM_O output through an RC low-pass filter to generate a smooth analog voltage.

Feed that voltage into an external comparator together with your input signal.

The comparator output then connects back to ui[0], closing the ADC loop.

## External hardware

no  external hardware used in this  project 
