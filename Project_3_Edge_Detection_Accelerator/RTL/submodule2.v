// ============================================================================
// Module: submodule2.v (line_buffer_fifo.v)
// Project: V-SPACE FPGA Build Challenge 2026 - Experiment 3 (Intermediate)
// Description: Dual line buffer shift registers generating a 3x3 pixel window.
// ============================================================================

`timescale 1ns / 1ps

module line_buffer_fifo #(
    parameter IMG_WIDTH = 640
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] pixel_in,
    input  wire       pixel_valid,

    output reg  [7:0] p11, p12, p13,
    output reg  [7:0] p21, p22, p23,
    output reg  [7:0] p31, p32, p33,
    output reg        window_valid
);

    // Two shift-register line buffers storing row N-2 and row N-1
    reg [7:0] line_buf_0 [0:IMG_WIDTH-1];
    reg [7:0] line_buf_1 [0:IMG_WIDTH-1];

    reg [$clog2(IMG_WIDTH)-1:0] col_cnt;
    reg [9:0]                   row_cnt;

    // Shift registers for the current sliding 3x3 kernel
    reg [7:0] row3_pixels [0:2];
    reg [7:0] row2_pixels [0:2];
    reg [7:0] row1_pixels [0:2];

    wire [7:0] buf0_out = line_buf_0[col_cnt];
    wire [7:0] buf1_out = line_buf_1[col_cnt];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_cnt      <= 0;
            row_cnt      <= 0;
            window_valid <= 1'b0;
            p11 <= 0; p12 <= 0; p13 <= 0;
            p21 <= 0; p22 <= 0; p23 <= 0;
            p31 <= 0; p32 <= 0; p33 <= 0;
        end else if (pixel_valid) begin
            // 1. Write incoming pixel into line buffers
            line_buf_0[col_cnt] <= buf1_out;
            line_buf_1[col_cnt] <= pixel_in;

            // 2. Shift into 3x3 window registers
            p13 <= buf0_out; p12 <= p13; p11 <= p12;
            p23 <= buf1_out; p22 <= p23; p21 <= p22;
            p33 <= pixel_in; p32 <= p33; p31 <= p32;

            // 3. Coordinate Tracking
            if (col_cnt >= IMG_WIDTH - 1) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1'b1;
            end else begin
                col_cnt <= col_cnt + 1'b1;
            end

            // 4. Window is valid once 2 full rows and 2 columns are ingested
            if (row_cnt >= 2 && col_cnt >= 2)
                window_valid <= 1'b1;
            else
                window_valid <= 1'b0;
        end else begin
            window_valid <= 1'b0;
        end
    end

endmodule
