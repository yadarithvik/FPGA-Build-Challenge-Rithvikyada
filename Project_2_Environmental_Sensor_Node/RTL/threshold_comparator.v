// ============================================================================
// File: threshold_comparator.v
// Project: GPIO-Based Environmental Sensor Node
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Description: Dynamic dual-level threshold alert engine with latched alarm
//              and acknowledge/snooze clearing.
// ============================================================================
`timescale 1ns / 1ps

module threshold_comparator (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] filtered_val,
    input  wire       sw_warn,
    input  wire       sw_alarm,
    input  wire       ack_btn,
    output reg        is_warning,
    output reg        is_alarm,
    output reg        alarm_latched
);
    // SW0 DOWN (0): 30 deg C threshold (Safe for 28 deg C baseline)
    // SW0 UP   (1): 28 deg C threshold (Warning triggers for 28 deg C baseline)
    wire [7:0] warn_thresh  = (sw_warn)  ? 8'd28 : 8'd30;
    // SW1 selects 35 deg C or 40 deg C critical alarm threshold
    wire [7:0] alarm_thresh = (sw_alarm) ? 8'd40 : 8'd35;

    initial begin
        is_warning    = 1'b0;
        is_alarm      = 1'b0;
        alarm_latched = 1'b0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_warning    <= 1'b0;
            is_alarm      <= 1'b0;
            alarm_latched <= 1'b0;
        end else begin
            is_warning <= (filtered_val >= warn_thresh && filtered_val < alarm_thresh);
            is_alarm   <= (filtered_val >= alarm_thresh);

            if (filtered_val >= alarm_thresh) begin
                alarm_latched <= 1'b1;
            end else if (ack_btn) begin
                alarm_latched <= 1'b0; // Snooze / Clear latched alarm
            end
        end
    end
endmodule
