// ============================================================================
// Module Name:  traffic_top
// Project:      Digital Traffic & Pedestrian Signal Controller using FSM
// Target Board: AMD PYNQ-Z2 (Zynq-7000 XC7Z020-1CLG400C)
// Description:  Top-Level integration module for PYNQ-Z2.
//               Instantiates clock divider, debouncers, and core FSM.
//               Drives onboard LEDs, RGB LEDs, and optional Pmod header.
// ============================================================================

`timescale 1ns / 1ps

module traffic_top (
    // Onboard 125 MHz Clock
    input  wire       sysclk,

    // Onboard Push Buttons (Active High)
    // btn[0]: Pedestrian Crossing Request
    // btn[1]: Emergency Vehicle Preemption Trigger
    // btn[2]: Side Street Vehicle Presence Sensor
    // btn[3]: Master Reset
    input  wire [3:0] btn,

    // Onboard Slide Switches
    // sw[0]: Emergency Override Persistent Switch
    // sw[1]: Demo Fast-Forward Mode (100x speedup)
    input  wire [1:0] sw,

    // Onboard 4 User LEDs (Main Street & Status)
    // led[0]: Main Green
    // led[1]: Main Yellow
    // led[2]: Main Red
    // led[3]: Emergency Active Indicator (Solid Green)
    output wire [3:0] led,

    // Onboard RGB LED 4 (Side Street Traffic Light)
    // Red (N15), Green (G17), Blue (L15)
    output wire       rgb_led4_r,
    output wire       rgb_led4_g,
    output wire       rgb_led4_b,

    // Onboard RGB LED 5 (Pedestrian Crosswalk Signal)
    // Red (M15), Green (L14), Blue (G14)
    output wire       rgb_led5_r,
    output wire       rgb_led5_g,
    output wire       rgb_led5_b,

    // External Pmod JA Header (Pins 1..10 for Breadboard Traffic LEDs)
    output wire [7:0] pmodja
);

    // ========================================================================
    // Internal Signals
    // ========================================================================
    wire rst = btn[3]; // System Reset from BTN3

    wire sec_tick;
    wire blink_tick;

    wire ped_pulse;
    wire ped_level;
    wire emer_pulse;
    wire emer_level;
    wire side_pulse;
    wire side_level;

    wire [2:0] main_lights;       // {Red, Yellow, Green}
    wire [2:0] side_lights;       // {Red, Yellow, Green}
    wire [1:0] ped_lights;        // {Don't Walk (Red), Walk (Green)}
    wire       ped_req_latched;
    wire       emergency_active;
    wire [2:0] current_state;
    wire [5:0] seconds_remaining;

    // ========================================================================
    // Clock Divider Instance
    // ========================================================================
    clock_divider #(
        .CLK_FREQ_HZ(32'd125_000_000),
        .FAST_DIV   (32'd1_250_000)
    ) u_clk_div (
        .clk       (sysclk),
        .rst       (rst),
        .fast_mode (sw[1]),
        .sec_tick  (sec_tick),
        .blink_tick(blink_tick)
    );

    // ========================================================================
    // Push Button Debouncers
    // ========================================================================
    debouncer u_deb_ped (
        .clk      (sysclk),
        .rst      (rst),
        .btn_in   (btn[0]),
        .btn_level(ped_level),
        .btn_pulse(ped_pulse)
    );

    debouncer u_deb_emer (
        .clk      (sysclk),
        .rst      (rst),
        .btn_in   (btn[1]),
        .btn_level(emer_level),
        .btn_pulse(emer_pulse)
    );

    debouncer u_deb_side (
        .clk      (sysclk),
        .rst      (rst),
        .btn_in   (btn[2]),
        .btn_level(side_level),
        .btn_pulse(side_pulse)
    );

    // ========================================================================
    // Traffic FSM Controller Instance
    // ========================================================================
    traffic_fsm #(
        .TIME_MAIN_GREEN (6'd10),
        .TIME_MAIN_YELLOW(6'd3),
        .TIME_ALL_RED_1  (6'd1),
        .TIME_SIDE_GREEN (6'd6),
        .TIME_SIDE_YELLOW(6'd3),
        .TIME_ALL_RED_2  (6'd1),
        .TIME_PED_WALK   (6'd5)
    ) u_traffic_fsm (
        .clk             (sysclk),
        .rst             (rst),
        .sec_tick        (sec_tick),
        .blink_tick      (blink_tick),
        .ped_btn_pulse   (ped_pulse),
        .emergency_pulse (emer_pulse),
        .emergency_switch(sw[0]),
        .side_sensor     (side_level),
        .main_lights     (main_lights),
        .side_lights     (side_lights),
        .ped_lights      (ped_lights),
        .ped_req_latched (ped_req_latched),
        .emergency_active(emergency_active),
        .current_state   (current_state),
        .seconds_remaining(seconds_remaining)
    );

    // ========================================================================
    // Peripheral Mappings
    // ========================================================================

            // 1. Single-color Onboard User LEDs
    assign led[0] = main_lights[0];      // Main Green
    assign led[1] = main_lights[1];      // Main Yellow
    assign led[2] = main_lights[2];      // Main Red
    assign led[3] = emergency_active;    // EMERGENCY ACTIVE INDICATOR (Solid Green LD3!)

    // 2. RGB LED 4 (Side Street Traffic Light) - Clean Pure Colors, NO Blue!
    assign rgb_led4_r = side_lights[2] | side_lights[1]; // Red or Yellow
    assign rgb_led4_g = side_lights[0] | side_lights[1]; // Green or Yellow
    assign rgb_led4_b = 1'b0;                            // Blue 100% OFF

    // 3. RGB LED 5 (Pedestrian Crosswalk Signal) - Clean Pure Colors, NO Blue!
    assign rgb_led5_r = ped_lights[1];                  // Don't Walk (Pure Red)
    assign rgb_led5_g = ped_lights[0];                  // Walk (Pure Green)
    assign rgb_led5_b = 1'b0;                           // Blue 100% OFF

    // 4. Pmod JA External Traffic Light Module Pins
    // Allows plugging in external 3-color LED modules on breadboard
    assign pmodja[0] = main_lights[2];   // JA1:  Main Red
    assign pmodja[1] = main_lights[1];   // JA2:  Main Yellow
    assign pmodja[2] = main_lights[0];   // JA3:  Main Green
    assign pmodja[3] = ped_lights[0];    // JA4:  Ped Walk (Green)
    assign pmodja[4] = side_lights[2];   // JA7:  Side Red
    assign pmodja[5] = side_lights[1];   // JA8:  Side Yellow
    assign pmodja[6] = side_lights[0];   // JA9:  Side Green
    assign pmodja[7] = ped_lights[1];    // JA10: Ped Don't Walk (Red)

endmodule
