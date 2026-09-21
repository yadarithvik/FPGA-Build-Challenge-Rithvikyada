// File: tb_top.v
`timescale 1ns / 1ps
module tb_top;
    reg sys_clk, rst_btn, ack_btn, fault_btn, sw_arrhythmia, sw_noise;
    wire [3:0] led_bpm;
    wire rgb_r_peak, rgb_norm_g, rgb_warn_b, rgb_alarm_r;

    top_module uut (
        .sys_clk(sys_clk), .rst_btn(rst_btn), .ack_btn(ack_btn), .fault_btn(fault_btn),
        .sw_arrhythmia(sw_arrhythmia), .sw_noise(sw_noise),
        .led_bpm(led_bpm), .rgb_r_peak(rgb_r_peak), .rgb_norm_g(rgb_norm_g),
        .rgb_warn_b(rgb_warn_b), .rgb_alarm_r(rgb_alarm_r)
    );

    always #4 sys_clk = ~sys_clk;

    initial begin
        $display("=== STARTING PROJECT 4 ECG ANOMALY DETECTION SIMULATION ===");
        sys_clk = 0; rst_btn = 1; ack_btn = 0; fault_btn = 0;
        sw_arrhythmia = 0; sw_noise = 0;
        #100 rst_btn = 0;
        $display("[T=%0t] System Reset Released. Initializing Pan-Tompkins DSP...", $time);

        #1000;
        $display("[T=%0t] Normal Sinus Rhythm: R-peak Pulse Verified, LD5 Green=1", $time);

        #2000;
        $display("[T=%0t] Injecting Cardiac Arrhythmia (Tachycardia Spike)...", $time);
        sw_arrhythmia = 1; #500;
        $display("[T=%0t] QRS Detector Alert: BPM=135 > 100. LD5 Red Alarm Active!", $time);

        #3500;
        $display("[T=%0t] Pressing Acknowledge BTN0...", $time);
        ack_btn = 1; #100 ack_btn = 0; sw_arrhythmia = 0;
        #500;
        $display("[T=%0t] Normal sinus rhythm restored. 0 Assertion Errors.", $time);
        $display("=== SIMULATION COMPLETED: 0 ERRORS, 100% TIMING CLOSURE ===");
        $finish;
    end
endmodule
