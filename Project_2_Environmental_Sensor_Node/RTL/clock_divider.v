// ============================================================================
// File: clock_divider.v
// Project: GPIO-Based Environmental Sensor Node
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Clock Source: 125 MHz onboard oscillator (Pin H16)
// ============================================================================
`timescale 1ns / 1ps

module clock_divider (
    input  wire clk,
    input  wire rst,
    output reg  clk_1khz,
    output reg  clk_1hz,
    output reg  blink_2hz
);
    reg [16:0] cnt_1k;
    reg [26:0] cnt_1s;
    reg [25:0] cnt_2hz;

`ifdef SIMULATION
    localparam [16:0] LIMIT_1K  = 17'd7;
    localparam [26:0] LIMIT_1S  = 27'd31;
    localparam [25:0] LIMIT_2HZ = 26'd15;
`else
    // 125 MHz master clock division for real PYNQ-Z2 hardware
    localparam [16:0] LIMIT_1K  = 17'd124999;     // 1 kHz tick (every 1 ms)
    localparam [26:0] LIMIT_1S  = 27'd124999999;  // 1 Hz tick (every 1 s)
    localparam [25:0] LIMIT_2HZ = 26'd31249999;   // 2 Hz visual alarm toggle (0.25 s half-period)
`endif

    initial begin
        cnt_1k    = 17'd0;
        cnt_1s    = 27'd0;
        cnt_2hz   = 26'd0;
        clk_1khz  = 1'b0;
        clk_1hz   = 1'b0;
        blink_2hz = 1'b0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_1k    <= 17'd0;
            cnt_1s    <= 27'd0;
            cnt_2hz   <= 26'd0;
            clk_1khz  <= 1'b0;
            clk_1hz   <= 1'b0;
            blink_2hz <= 1'b0;
        end else begin
            // 1 kHz sampling tick
            if (cnt_1k >= LIMIT_1K) begin
                cnt_1k   <= 17'd0;
                clk_1khz <= 1'b1;
            end else begin
                cnt_1k   <= cnt_1k + 17'd1;
                clk_1khz <= 1'b0;
            end

            // 1 Hz heartbeat tick
            if (cnt_1s >= LIMIT_1S) begin
                cnt_1s  <= 27'd0;
                clk_1hz <= 1'b1;
            end else begin
                cnt_1s  <= cnt_1s + 27'd1;
                clk_1hz <= 1'b0;
            end

            // 2 Hz square wave for visual flashing
            if (cnt_2hz >= LIMIT_2HZ) begin
                cnt_2hz   <= 26'd0;
                blink_2hz <= ~blink_2hz;
            end else begin
                cnt_2hz   <= cnt_2hz + 26'd1;
            end
        end
    end
endmodule
