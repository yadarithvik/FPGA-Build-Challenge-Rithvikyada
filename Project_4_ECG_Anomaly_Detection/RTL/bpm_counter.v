// File: bpm_counter.v
`timescale 1ns / 1ps
module bpm_counter (
    input  wire       clk,
    input  wire       rst,
    input  wire       sample_tick,
    input  wire       qrs_pulse,
    output reg  [7:0] bpm
);
    reg [15:0] rr_samples;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rr_samples <= 16'd0;
            bpm <= 8'd72; // Nominal 72 BPM
        end else if (sample_tick) begin
            if (qrs_pulse) begin
                // Rate estimation: 200 Hz * 60 / rr_samples = 12000 / rr_samples
                if (rr_samples < 16'd90) bpm <= 8'd135;       // Tachycardia
                else if (rr_samples > 16'd250) bpm <= 8'd48;  // Bradycardia
                else bpm <= 8'd75;                            // Normal
                rr_samples <= 16'd0;
            end else begin
                rr_samples <= rr_samples + 16'd1;
            end
        end
    end
endmodule
