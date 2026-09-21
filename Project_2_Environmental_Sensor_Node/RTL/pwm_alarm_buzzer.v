// ============================================================================
// File: pwm_alarm_buzzer.v
// Project: GPIO-Based Environmental Sensor Node
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Description: Dual-frequency PWM buzzer driver:
//              - Critical Alarm: Loud continuous 3.8 kHz siren (cnt[14])
//              - Warning State: Intermittent ~950 Hz chirp gated by blink_tick
//              - Safe State: Silent (0)
// ============================================================================
`timescale 1ns / 1ps

module pwm_alarm_buzzer (
    input  wire clk,
    input  wire rst,
    input  wire is_warning,
    input  wire is_alarm,
    input  wire alarm_latched,
    input  wire blink_tick,
    output reg  buzzer_out
);
    reg [16:0] cnt;

    initial begin
        cnt        = 17'd0;
        buzzer_out = 1'b0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt        <= 17'd0;
            buzzer_out <= 1'b0;
        end else begin
            cnt <= cnt + 17'd1;
            if (alarm_latched) begin
                buzzer_out <= cnt[14]; // Loud continuous 3.8 kHz siren
            end else if (is_warning) begin
                buzzer_out <= cnt[16] & blink_tick; // ~950 Hz intermittent chirp
            end else begin
                buzzer_out <= 1'b0;
            end
        end
    end
endmodule
