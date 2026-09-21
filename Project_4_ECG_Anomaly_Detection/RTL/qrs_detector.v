// File: qrs_detector.v
`timescale 1ns / 1ps
module qrs_detector (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_in,
    input  wire [15:0] mwi_in,
    output reg         qrs_pulse
);
    reg [15:0] thresh_sig = 16'd12000;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            qrs_pulse <= 1'b0;
        end else if (valid_in) begin
            if (mwi_in > thresh_sig) begin
                qrs_pulse <= 1'b1;
            end else begin
                qrs_pulse <= 1'b0;
            end
        end else begin
            qrs_pulse <= 1'b0;
        end
    end
endmodule
