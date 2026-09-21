// File: derivative_squarer.v
`timescale 1ns / 1ps
module derivative_squarer (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_in,
    input  wire [11:0] data_in,
    output reg  [15:0] mwi_out
);
    reg [11:0] d1, d2, d3, d4;
    reg signed [12:0] deriv;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            d1 <= 12'd2048; d2 <= 12'd2048; d3 <= 12'd2048; d4 <= 12'd2048;
            deriv <= 13'sd0;
            mwi_out <= 16'd0;
        end else if (valid_in) begin
            d1 <= data_in; d2 <= d1; d3 <= d2; d4 <= d3;
            // 5-point derivative: (2*data_in + d1 - d3 - 2*d4)/8
            deriv <= (data_in << 1) + d1 - d3 - (d4 << 1);
            // Squaring function
            mwi_out <= (deriv < 0) ? ((-deriv) * (-deriv)) : (deriv * deriv);
        end
    end
endmodule
