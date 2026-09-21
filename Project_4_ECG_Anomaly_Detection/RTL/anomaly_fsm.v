// File: anomaly_fsm.v
`timescale 1ns / 1ps
module anomaly_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] bpm,
    input  wire       ack_btn,
    output reg        is_tachy,
    output reg        is_brady,
    output reg        is_asystole
);
    reg latched_alarm;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_tachy <= 1'b0;
            is_brady <= 1'b0;
            is_asystole <= 1'b0;
            latched_alarm <= 1'b0;
        end else begin
            if (bpm > 8'd100) begin
                is_tachy <= 1'b1;
                latched_alarm <= 1'b1;
            end else if (bpm < 8'd60) begin
                is_brady <= 1'b1;
            end else begin
                is_tachy <= 1'b0;
                is_brady <= 1'b0;
            end

            if (ack_btn) latched_alarm <= 1'b0;
            is_asystole <= latched_alarm;
        end
    end
endmodule
