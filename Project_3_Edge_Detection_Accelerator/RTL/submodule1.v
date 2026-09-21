// ============================================================================
// Module: submodule1.v (sobel_kernel_3x3.v)
// Project: V-SPACE FPGA Build Challenge 2026 - Experiment 3 (Intermediate)
// Description: Computes horizontal and vertical Sobel gradients and applies threshold.
// ============================================================================

`timescale 1ns / 1ps

module sobel_kernel_3x3 (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       window_valid,
    input  wire [7:0] threshold_val,

    // 3x3 Neighborhood Pixels
    input  wire [7:0] p11, p12, p13,
    input  wire [7:0] p21, p22, p23,
    input  wire [7:0] p31, p32, p33,

    output reg  [7:0] edge_pixel,
    output reg        edge_valid
);

    // Pipelined intermediate registers
    reg signed [10:0] gx;
    reg signed [10:0] gy;
    reg signed [10:0] abs_gx;
    reg signed [10:0] abs_gy;
    reg [11:0]        grad_mag;
    reg               val_d1, val_d2;

    // Stage 1: Convolution Kernels
    // Gx = (P13 + 2*P23 + P33) - (P11 + 2*P21 + P31)
    // Gy = (P31 + 2*P32 + P33) - (P11 + 2*P12 + P13)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gx     <= 11'sd0;
            gy     <= 11'sd0;
            val_d1 <= 1'b0;
        end else begin
            val_d1 <= window_valid;
            gx     <= ($signed({3'b000, p13}) + $signed({2'b00, p23, 1'b0}) + $signed({3'b000, p33})) -
                      ($signed({3'b000, p11}) + $signed({2'b00, p21, 1'b0}) + $signed({3'b000, p31}));

            gy     <= ($signed({3'b000, p31}) + $signed({2'b00, p32, 1'b0}) + $signed({3'b000, p33})) -
                      ($signed({3'b000, p11}) + $signed({2'b00, p12, 1'b0}) + $signed({3'b000, p13}));
        end
    end

    // Stage 2: Absolute Value and Manhattan Gradient Approximation: |Gx| + |Gy|
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            abs_gx   <= 11'sd0;
            abs_gy   <= 11'sd0;
            grad_mag <= 12'd0;
            val_d2   <= 1'b0;
        end else begin
            val_d2   <= val_d1;
            abs_gx   <= (gx < 0) ? -gx : gx;
            abs_gy   <= (gy < 0) ? -gy : gy;
            grad_mag <= abs_gx + abs_gy;
        end
    end

    // Stage 3: Threshold Comparator
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            edge_pixel <= 8'd0;
            edge_valid <= 1'b0;
        end else begin
            edge_valid <= val_d2;
            if (val_d2) begin
                if (grad_mag >= {4'd0, threshold_val})
                    edge_pixel <= 8'hFF; // White Edge
                else
                    edge_pixel <= 8'h00; // Black Background
            end else begin
                edge_pixel <= 8'h00;
            end
        end
    end

endmodule
