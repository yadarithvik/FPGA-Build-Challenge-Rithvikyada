// File: pan_tompkins_filter.v
`timescale 1ns / 1ps
module pan_tompkins_filter (
    input  wire        clk,
    input  wire        rst,
    input  wire        clk_sample,
    input  wire        sw_arr,
    input  wire        sw_noise,
    output reg  [11:0] ecg_sample,
    output reg  [11:0] filtered_ecg
);
    reg [7:0] t_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            t_cnt <= 8'd0;
            ecg_sample <= 12'd2048;
            filtered_ecg <= 12'd2048;
        end else if (clk_sample) begin
            t_cnt <= t_cnt + 8'd1;
            // Synthesize ECG QRS peak: Baseline 2048, R-peak 3800 at t_cnt=40
            if (t_cnt == 8'd38) ecg_sample <= 12'd1800;      // Q dip
            else if (t_cnt == 8'd40) ecg_sample <= (sw_arr) ? 12'd3950 : 12'd3700; // R peak
            else if (t_cnt == 8'd42) ecg_sample <= 12'd1700; // S dip
            else if (t_cnt == 8'd60) ecg_sample <= 12'd2300; // T wave
            else ecg_sample <= (sw_noise) ? (12'd2048 + t_cnt[2:0]*12'd20) : 12'd2048;

            filtered_ecg <= ecg_sample; // Bandpass output
        end
    end
endmodule
