// ============================================================================
// Module: top_module.v (sobel_accel_top.v)
// Project: V-SPACE FPGA Build Challenge 2026 - Experiment 3 (Intermediate)
// Title: PYNQ-Based Real-Time Edge Detection Accelerator
// Description: AXI4-Stream 2D Convolution Sobel Edge Detection Accelerator.
// ============================================================================

`timescale 1ns / 1ps

module top_module #(
    parameter IMG_WIDTH  = 640,
    parameter IMG_HEIGHT = 480,
    parameter DATA_WIDTH = 8
)(
    input  wire                  clk,            // AXI-Stream Clock (100 MHz)
    input  wire                  rst_n,          // Active-Low Reset

    // AXI4-Stream Slave Interface (Input Grayscale Pixels from DMA)
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire                  s_axis_tvalid,
    output wire                  s_axis_tready,
    input  wire                  s_axis_tlast,

    // AXI4-Stream Master Interface (Output Binary Edge Pixels to DMA)
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast,

    // Dynamic Threshold Configuration
    input  wire [DATA_WIDTH-1:0] threshold_val,  // Edge sensitivity cutoff (e.g., 80)

    // Board Status LEDs
    output wire [3:0]            status_leds
);

    assign s_axis_tready = m_axis_tready; // Simple pass-through flow control

    // 1. Line Buffers providing 3x3 Window
    wire [7:0] p11, p12, p13;
    wire [7:0] p21, p22, p23;
    wire [7:0] p31, p32, p33;
    wire       window_valid;

    line_buffer_fifo #(
        .IMG_WIDTH(IMG_WIDTH)
    ) u_line_buffers (
        .clk          (clk),
        .rst_n        (rst_n),
        .pixel_in     (s_axis_tdata),
        .pixel_valid  (s_axis_tvalid && s_axis_tready),
        .p11(p11), .p12(p12), .p13(p13),
        .p21(p21), .p22(p22), .p23(p23),
        .p31(p31), .p32(p32), .p33(p33),
        .window_valid (window_valid)
    );

    // 2. 3x3 Sobel Convolution Core
    wire [7:0] edge_pixel;
    wire       edge_valid;

    sobel_kernel_3x3 u_sobel_core (
        .clk           (clk),
        .rst_n         (rst_n),
        .window_valid  (window_valid),
        .threshold_val (threshold_val),
        .p11(p11), .p12(p12), .p13(p13),
        .p21(p21), .p22(p22), .p23(p23),
        .p31(p31), .p32(p32), .p33(p33),
        .edge_pixel    (edge_pixel),
        .edge_valid    (edge_valid)
    );

    assign m_axis_tdata  = edge_pixel;
    assign m_axis_tvalid = edge_valid;
    assign m_axis_tlast  = s_axis_tlast; // Pass end-of-frame

    // Status Indicators: LD0 = Processing, LD1 = Edge Detected
    assign status_leds[0] = s_axis_tvalid;
    assign status_leds[1] = (edge_pixel == 8'hFF);
    assign status_leds[2] = 1'b0;
    assign status_leds[3] = 1'b1; // Accelerator Ready

endmodule
