// ============================================================================
// File: top_module.v
// Project: FPGA-Accelerated Real-Time ECG Signal Anomaly Detection System
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Team: TEAM BVD-26 (Yada Rithvik, Neelkorak Jana, Anirudh Dodia)
// ============================================================================
`timescale 1ns / 1ps

module top_module (
    input  wire        sys_clk,      // 125 MHz onboard oscillator (Pin H16)
    input  wire        rst_btn,      // BTN3: Master synchronous reset
    input  wire        ack_btn,      // BTN0: Clear / Acknowledge Arrhythmia Alarm
    input  wire        fault_btn,    // BTN1: Inject synthetic cardiac arrhythmia burst
    input  wire        sw_arrhythmia,// SW0: Cardiac rhythm mode (0=Normal, 1=Arrhythmia)
    input  wire        sw_noise,     // SW1: Enable muscle tremor / EMG noise filter test
    output wire [3:0]  led_bpm,      // LD0-LD3: Real-time Heart Rate (BPM) bracket
    output wire        rgb_r_peak,   // LD4 Green: R-peak QRS heartbeat flash
    output wire        rgb_norm_g,   // LD5 Green: Normal sinus rhythm (60-100 BPM)
    output wire        rgb_warn_b,   // LD5 Blue: Bradycardia (<60 BPM)
    output wire        rgb_alarm_r   // LD5 Red: Critical Tachycardia / Arrhythmia alarm
);

    wire rst, ack_clean, fault_clean;
    wire clk_200hz, blink_2hz;
    wire [11:0] ecg_raw, filtered_ecg;
    wire [15:0] mwi_signal;
    wire qrs_detected;
    wire [7:0] bpm_value;
    wire is_tachy, is_brady, is_asystole;

    debouncer db_rst   (.clk(sys_clk), .btn_in(rst_btn),   .btn_out(rst));
    debouncer db_ack   (.clk(sys_clk), .btn_in(ack_btn),   .btn_out(ack_clean));
    debouncer db_fault (.clk(sys_clk), .btn_in(fault_btn), .btn_out(fault_clean));

    // Clock generator (125 MHz -> 200 Hz ECG sampling tick & 2 Hz flasher)
    clock_divider clk_gen (
        .clk(sys_clk), .rst(rst),
        .clk_200hz(clk_200hz),
        .blink_2hz(blink_2hz)
    );

    // Synthetic ECG Stream Generator (Emulates MIT-BIH Arrhythmia Database pattern)
    pan_tompkins_filter ecg_stream (
        .clk(sys_clk), .rst(rst), .clk_sample(clk_200hz),
        .sw_arr(sw_arrhythmia | fault_clean),
        .sw_noise(sw_noise),
        .ecg_sample(ecg_raw),
        .filtered_ecg(filtered_ecg)
    );

    // Five-point Derivative & Squarer Pipeline
    derivative_squarer diff_sq (
        .clk(sys_clk), .rst(rst), .valid_in(clk_200hz),
        .data_in(filtered_ecg),
        .mwi_out(mwi_signal)
    );

    // Adaptive Dual-Threshold QRS Peak Detector
    qrs_detector qrs_core (
        .clk(sys_clk), .rst(rst), .valid_in(clk_200hz),
        .mwi_in(mwi_signal),
        .qrs_pulse(qrs_detected)
    );

    // Real-Time BPM Counter & R-to-R Interval Estimator
    bpm_counter bpm_calc (
        .clk(sys_clk), .rst(rst),
        .sample_tick(clk_200hz),
        .qrs_pulse(qrs_detected),
        .bpm(bpm_value)
    );

    // Arrhythmia Classification FSM
    anomaly_fsm classifier (
        .clk(sys_clk), .rst(rst),
        .bpm(bpm_value),
        .ack_btn(ack_clean),
        .is_tachy(is_tachy),
        .is_brady(is_brady),
        .is_asystole(is_asystole)
    );

    assign led_bpm     = bpm_value[7:4];
    assign rgb_r_peak  = qrs_detected;
    assign rgb_norm_g  = (!is_tachy && !is_brady && !is_asystole);
    assign rgb_warn_b  = is_brady;
    assign rgb_alarm_r = (is_tachy || is_asystole) ? blink_2hz : 1'b0;

endmodule
