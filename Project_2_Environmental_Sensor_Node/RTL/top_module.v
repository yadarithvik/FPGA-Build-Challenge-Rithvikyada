// ============================================================================
// File: top_module.v
// Project: GPIO-Based Environmental Sensor Node with Real-Time Threshold Alerts
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Team: TEAM BVD-26 (Yada Rithvik, Neelkorak Jana, Anirudh Dodia)
// ============================================================================
`timescale 1ns / 1ps

module top_module (
    input  wire        sys_clk,      // 125 MHz onboard oscillator (Pin H16)
    input  wire        rst_btn,      // BTN3: Master synchronous reset (Pin L19)
    input  wire        ack_btn,      // BTN0: Alarm acknowledge / snooze (Pin D19)
    input  wire        fault_btn,    // BTN1: Inject synthetic threshold fault (Pin D20)
    input  wire        sw_warn_sel,  // SW0: Warning threshold select (Pin M20)
    input  wire        sw_alarm_sel, // SW1: Alarm threshold select (Pin M19)
    input  wire        sensor_sdata, // Pmod JA Pin 1 (Y18): Serial sensor data in
    output wire        sensor_sclk,  // Pmod JA Pin 2 (Y19): Serial sensor clock out
    output wire [3:0]  led_level,    // LD0-LD3: Current 4-bit filtered sensor nibble
    output wire        rgb_safe_g,   // LD4 Green: Safe / Normal status (Pin G17)
    output wire        rgb_warn_b,   // LD4 Blue: Warning state (Pin L15)
    output wire        rgb_alarm_r,  // LD4 Red: Critical Alarm state (Pin N15)
    output wire        rgb_flt_r,    // LD5 Red: Sensor communication fault (Pin M15)
    output wire        rgb_flt_g,    // LD5 Green: Active sampling pulse (Pin L14)
    output wire        buzzer_pwm    // Pmod JA Pin 3 (Y16): Piezo buzzer PWM
);

    wire rst, ack_clean, fault_clean;
    wire clk_1khz, clk_1hz, blink_2hz;
    wire [7:0] raw_sensor_val;
    wire [7:0] filtered_val;
    wire sensor_valid, sensor_err;
    wire is_warning, is_alarm, alarm_latched;

    // Button Debouncers
    debouncer db_rst (.clk(sys_clk), .btn_in(rst_btn), .btn_out(rst));
    debouncer db_ack (.clk(sys_clk), .btn_in(ack_btn), .btn_out(ack_clean));
    debouncer db_flt (.clk(sys_clk), .btn_in(fault_btn), .btn_out(fault_clean));

    // Clock Dividers
    clock_divider clk_gen (
        .clk(sys_clk),
        .rst(rst),
        .clk_1khz(clk_1khz),
        .clk_1hz(clk_1hz),
        .blink_2hz(blink_2hz)
    );

    // Sensor Sampler
    sensor_sampler sampler (
        .clk(sys_clk),
        .rst(rst),
        .clk_1khz(clk_1khz),
        .fault_inject(fault_clean),
        .sensor_sdata(sensor_sdata),
        .sensor_sclk(sensor_sclk),
        .sensor_data(raw_sensor_val),
        .data_valid(sensor_valid),
        .sensor_error(sensor_err)
    );

    // 4-tap Moving Average Digital Filter
    digital_filter filter (
        .clk(sys_clk),
        .rst(rst),
        .valid_in(sensor_valid),
        .data_in(raw_sensor_val),
        .filtered_out(filtered_val)
    );

    // Dynamic Threshold Comparator & Alarm Engine
    threshold_comparator comp (
        .clk(sys_clk),
        .rst(rst),
        .filtered_val(filtered_val),
        .sw_warn(sw_warn_sel),
        .sw_alarm(sw_alarm_sel),
        .ack_btn(ack_clean),
        .is_warning(is_warning),
        .is_alarm(is_alarm),
        .alarm_latched(alarm_latched)
    );

    // Audible PWM Alert Generator
    pwm_alarm_buzzer buzzer (
        .clk(sys_clk),
        .rst(rst),
        .is_warning(is_warning),
        .is_alarm(is_alarm),
        .alarm_latched(alarm_latched),
        .blink_tick(blink_2hz),
        .buzzer_out(buzzer_pwm)
    );

    // Output Indicators
    assign led_level   = filtered_val[7:4];
    assign rgb_safe_g  = (!is_warning && !alarm_latched && !sensor_err);
    assign rgb_warn_b  = (is_warning && !alarm_latched);
    assign rgb_alarm_r = (alarm_latched) ? blink_2hz : 1'b0;
    assign rgb_flt_r   = sensor_err;
    assign rgb_flt_g   = sensor_valid;

endmodule
