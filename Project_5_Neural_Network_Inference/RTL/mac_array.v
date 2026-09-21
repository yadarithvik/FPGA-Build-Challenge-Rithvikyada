// File: mac_array.v
`timescale 1ns / 1ps
module mac_array (
    input  wire signed [7:0] x0, x1, x2, x3,
    output wire signed [15:0] n0, n1, n2, n3
);
    // Hardcoded INT8 trained weights for demo model
    wire signed [7:0] w00 = 8'sd2,  w01 = 8'sd1,  w02 = -8'sd1, w03 = 8'sd3;
    wire signed [7:0] w10 = -8'sd1, w11 = 8'sd3,  w12 = 8'sd2,  w13 = -8'sd2;
    wire signed [7:0] w20 = 8'sd1,  w21 = -8'sd2, w22 = 8'sd4,  w23 = 8'sd1;
    wire signed [7:0] w30 = -8'sd2, w31 = -8'sd1, w32 = -8'sd3, w33 = -8'sd2;

    assign n0 = (x0*w00) + (x1*w01) + (x2*w02) + (x3*w03);
    assign n1 = (x0*w10) + (x1*w11) + (x2*w12) + (x3*w13);
    assign n2 = (x0*w20) + (x1*w21) + (x2*w22) + (x3*w23);
    assign n3 = (x0*w30) + (x1*w31) + (x2*w32) + (x3*w33);
endmodule
