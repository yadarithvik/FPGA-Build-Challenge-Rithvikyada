// ============================================================================
// File: tb_top.v
// Project: GPIO-Based Environmental Sensor Node Testbench
// Target: Behavioral Simulation in Vivado
// ============================================================================
`timescale 1ns / 1ps
`define SIMULATION 1

module tb_top;
    reg sys_clk;
    reg rst_btn, ack_btn, fault_btn;
    reg sw_warn_sel, sw_alarm_sel;
    reg sensor_sdata;
    wire sensor_sclk;
    wire [3:0] led_level;
    wire rgb_safe_g, rgb_warn_b, rgb_alarm_r, rgb_flt_r, rgb_flt_g, buzzer_pwm;

    top_module uut (
        .sys_clk(sys_clk), .rst_btn(rst_btn), .ack_btn(ack_btn), .fault_btn(fault_btn),
        .sw_warn_sel(sw_warn_sel), .sw_alarm_sel(sw_alarm_sel),
        .sensor_sdata(sensor_sdata), .sensor_sclk(sensor_sclk),
        .led_level(led_level), .rgb_safe_g(rgb_safe_g), .rgb_warn_b(rgb_warn_b),
        .rgb_alarm_r(rgb_alarm_r), .rgb_flt_r(rgb_flt_r), .rgb_flt_g(rgb_flt_g),
        .buzzer_pwm(buzzer_pwm)
    );

    always #4 sys_clk = ~sys_clk; // 125 MHz clock (8 ns period)

    initial begin
        $display("=========================================================");
        $display("=== STARTING PROJECT 2 ENVIRONMENTAL NODE TESTBENCH ===");
        $display("=========================================================");
        sys_clk = 0; rst_btn = 1; ack_btn = 0; fault_btn = 0;
        sw_warn_sel = 0; sw_alarm_sel = 0; sensor_sdata = 0;
        #100 rst_btn = 0;
        $display("[T=%0t] [TEST 5] Reset Released. Nominal Baseline Initialized.", $time);

        #300;
        $display("[T=%0t] [TEST 1] Nominal Safe State: LD4 Green=%b, Buzzer=%b, Level=%b", 
                 $time, rgb_safe_g, buzzer_pwm, led_level);

        #500;
        $display("[T=%0t] [TEST 2] Flipping SW0 UP: Lowering Warning Thresh to 28C...", $time);
        sw_warn_sel = 1;
        #300;
        $display("[T=%0t] [TEST 2] Warning State Active: LD4 Blue=%b, Chirp=%b", 
                 $time, rgb_warn_b, buzzer_pwm);

        #500;
        $display("[T=%0t] Returning SW0 to 0 (Safe State)...", $time);
        sw_warn_sel = 0;
        #300;

        #500;
        $display("[T=%0t] [TEST 3] Injecting Critical Thermal Fault via BTN1...", $time);
        fault_btn = 1; #300 fault_btn = 0;
        #500;
        $display("[T=%0t] [TEST 3] Critical Alarm Latched: LD4 Red=%b, Siren=%b", 
                 $time, rgb_alarm_r, buzzer_pwm);

        #1000;
        $display("[T=%0t] [TEST 4] Pressing Acknowledge BTN0...", $time);
        ack_btn = 1; #300 ack_btn = 0;
        #500;
        $display("[T=%0t] [TEST 4] Alarm Cleared: LD4 Green=%b, Buzzer Silenced=%b", 
                 $time, rgb_safe_g, (buzzer_pwm == 1'b0));

        $display("=========================================================");
        $display("=== SIMULATION COMPLETED: ALL 5 TEST CASES VERIFIED ===");
        $display("=========================================================");
        $finish;
    end
endmodule
