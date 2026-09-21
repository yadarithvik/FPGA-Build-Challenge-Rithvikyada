// ============================================================================
// Module Name:  clock_divider
// Project:      Digital Traffic & Pedestrian Signal Controller using FSM
// Target Board: AMD PYNQ-Z2 (Zynq-7000 XC7Z020-1CLG400C)
// Clock Source: 125 MHz onboard oscillator (Pin H16)
// Description:  Generates a 1-clock-cycle pulse every 1 second (1 Hz tick).
//               Includes a fast demo/simulation mode (fast_mode) to accelerate
//               timing 100x for judge demonstrations and rapid test verification.
// ============================================================================

`timescale 1ns / 1ps

module clock_divider #(
    parameter CLK_FREQ_HZ = 32'd125_000_000, // 125 MHz master clock on PYNQ-Z2
    parameter FAST_DIV    = 32'd1_250_000    // 100x speedup for live demo (100 Hz tick)
)(
    input  wire clk,        // 125 MHz system clock
    input  wire rst,        // Synchronous active-high reset
    input  wire fast_mode,  // Slide switch: 0 = Real-time (1 Hz), 1 = Demo speedup (100 Hz)
    output reg  sec_tick,   // 1-cycle enable pulse
    output reg  blink_tick  // 2 Hz toggle pulse for flashing pedestrian warning
);

    reg [31:0] sec_counter;
    reg [31:0] blink_counter;
    wire [31:0] target_limit;
    wire [31:0] blink_limit;

    // Select counter limit based on mode switch
    assign target_limit = fast_mode ? (FAST_DIV - 1'b1) : (CLK_FREQ_HZ - 1'b1);
    // Blink at 2 Hz in normal mode (every 0.25s toggle = 2 Hz flash)
    assign blink_limit  = fast_mode ? (FAST_DIV / 4 - 1'b1) : (CLK_FREQ_HZ / 4 - 1'b1);

    // 1-Second Tick Generator
    always @(posedge clk) begin
        if (rst) begin
            sec_counter <= 32'd0;
            sec_tick    <= 1'b0;
        end else begin
            if (sec_counter >= target_limit) begin
                sec_counter <= 32'd0;
                sec_tick    <= 1'b1;
            end else begin
                sec_counter <= sec_counter + 1'b1;
                sec_tick    <= 1'b0;
            end
        end
    end

    // Pedestrian Warning Flasher Tick (2 Hz blink rate)
    always @(posedge clk) begin
        if (rst) begin
            blink_counter <= 32'd0;
            blink_tick    <= 1'b0;
        end else begin
            if (blink_counter >= blink_limit) begin
                blink_counter <= 32'd0;
                blink_tick    <= ~blink_tick;
            end else begin
                blink_counter <= blink_counter + 1'b1;
            end
        end
    end

endmodule
