// File: activation_relu.v
`timescale 1ns / 1ps
module activation_relu (
    input  wire signed [7:0] in_val,
    output wire signed [7:0] out_val
);
    assign out_val = (in_val < 8'sd0) ? 8'sd0 : in_val;
endmodule
