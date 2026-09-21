// File: clock_divider.v
`timescale 1ns / 1ps
module clock_divider (
    input  wire clk,
    input  wire rst,
    output reg  clk_200hz,
    output reg  blink_2hz
);
    reg [19:0] cnt_sample;
    reg [25:0] cnt_blink;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_sample <= 20'd0; clk_200hz <= 1'b0;
            cnt_blink  <= 26'd0; blink_2hz <= 1'b0;
        end else begin
            // 200 Hz tick: 125,000,000 / 625,000 = 200 Hz
            if (cnt_sample >= 20'd624999) begin
                cnt_sample <= 20'd0; clk_200hz <= 1'b1;
            end else begin
                cnt_sample <= cnt_sample + 20'd1; clk_200hz <= 1'b0;
            end

            // 2 Hz blink wave
            if (cnt_blink >= 26'd31249999) begin
                cnt_blink <= 26'd0; blink_2hz <= ~blink_2hz;
            end else begin
                cnt_blink <= cnt_blink + 26'd1;
            end
        end
    end
endmodule
