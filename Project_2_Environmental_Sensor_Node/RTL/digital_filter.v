// ============================================================================
// File: digital_filter.v
// Project: GPIO-Based Environmental Sensor Node
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Description: 4-tap Moving Average Filter. Clears to 28 deg C baseline on rst.
// ============================================================================
`timescale 1ns / 1ps

module digital_filter (
    input  wire       clk,
    input  wire       rst,
    input  wire       valid_in,
    input  wire [7:0] data_in,
    output reg  [7:0] filtered_out
);
    reg [7:0] tap0, tap1, tap2, tap3;
    wire [9:0] sum;

    assign sum = tap0 + tap1 + tap2 + tap3;

    initial begin
        tap0         = 8'd28;
        tap1         = 8'd28;
        tap2         = 8'd28;
        tap3         = 8'd28;
        filtered_out = 8'd28;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tap0         <= 8'd28;
            tap1         <= 8'd28;
            tap2         <= 8'd28;
            tap3         <= 8'd28;
            filtered_out <= 8'd28;
        end else if (valid_in) begin
            tap0         <= data_in;
            tap1         <= tap0;
            tap2         <= tap1;
            tap3         <= tap2;
            filtered_out <= sum[9:2]; // Running average: sum / 4
        end
    end
endmodule
