// ============================================================================
// File: sensor_sampler.v
// Project: GPIO-Based Environmental Sensor Node
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Description: Real-time sensor interface with baseline 28 deg C reading and
//              synthetic fault excursion on fault_inject (BTN1).
// ============================================================================
`timescale 1ns / 1ps

module sensor_sampler (
    input  wire       clk,
    input  wire       rst,
    input  wire       clk_1khz,
    input  wire       fault_inject,
    input  wire       sensor_sdata,
    output reg        sensor_sclk,
    output reg [7:0]  sensor_data,
    output reg        data_valid,
    output reg        sensor_error
);
    initial begin
        sensor_sclk  = 1'b0;
        sensor_data  = 8'd28; // Nominal baseline: 28 deg C
        data_valid   = 1'b0;
        sensor_error = 1'b0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sensor_sclk  <= 1'b0;
            sensor_data  <= 8'd28; // Reset baseline: 28 deg C
            data_valid   <= 1'b0;
            sensor_error <= 1'b0;
        end else if (clk_1khz) begin
            sensor_sclk <= ~sensor_sclk; // External clock monitor toggle (Pmod JA Pin 2)
            data_valid  <= 1'b1;
            if (fault_inject) begin
                // Injected critical thermal/gas excursion >= 35 deg C
                sensor_error <= 1'b1;
                sensor_data  <= 8'd48;
            end else begin
                // Nominal baseline: 28 deg C
                sensor_error <= 1'b0;
                sensor_data  <= 8'd28;
            end
        end else begin
            data_valid <= 1'b0;
        end
    end
endmodule
