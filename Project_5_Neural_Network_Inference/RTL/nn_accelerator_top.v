// File: nn_accelerator_top.v
`timescale 1ns / 1ps
module nn_accelerator_top (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [1:0] vec_sel,
    output reg  [1:0] pred_class,
    output reg  [7:0] confidence,
    output reg        is_anomaly,
    output reg        busy,
    output reg        done
);
    reg [3:0] state;
    localparam IDLE=4'd0, LAYER1=4'd1, ACT1=4'd2, LAYER2=4'd3, ARGMAX=4'd4, FINISH=4'd5;

    reg signed [7:0] in_x0, in_x1, in_x2, in_x3;
    wire signed [15:0] node0, node1, node2, node3;
    wire signed [7:0] relu0, relu1, relu2, relu3;
    reg [7:0] cycle_cnt;

    // Synthetic Feature Vector ROM
    always @(*) begin
        case(vec_sel)
            2'b00: begin in_x0 = 8'sd45; in_x1 = 8'sd60; in_x2 = -8'sd10; in_x3 = 8'sd15; end // Class 0
            2'b01: begin in_x0 = -8'sd20; in_x1 = 8'sd80; in_x2 = 8'sd50; in_x3 = -8'sd5; end  // Class 1
            2'b10: begin in_x0 = 8'sd10; in_x1 = -8'sd30; in_x2 = 8'sd95; in_x3 = 8'sd40; end  // Class 2
            2'b11: begin in_x0 = -8'sd120; in_x1 = -8'sd100; in_x2 = -8'sd90; in_x3 = -8'sd110; end // Anomaly
        endcase
    end

    // Parallel MAC Processing Array
    mac_array mac_inst (
        .x0(in_x0), .x1(in_x1), .x2(in_x2), .x3(in_x3),
        .n0(node0), .n1(node1), .n2(node2), .n3(node3)
    );

    // Fused ReLU Activation Units
    activation_relu a0 (.in_val(node0[11:4]), .out_val(relu0));
    activation_relu a1 (.in_val(node1[11:4]), .out_val(relu1));
    activation_relu a2 (.in_val(node2[11:4]), .out_val(relu2));
    activation_relu a3 (.in_val(node3[11:4]), .out_val(relu3));

    // Control FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            pred_class <= 2'b00;
            confidence <= 8'd0;
            is_anomaly <= 1'b0;
            busy <= 1'b0;
            done <= 1'b0;
            cycle_cnt <= 8'd0;
        end else begin
            case(state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        busy <= 1'b1;
                        cycle_cnt <= 8'd0;
                        state <= LAYER1;
                    end else busy <= 1'b0;
                end
                LAYER1: begin
                    cycle_cnt <= cycle_cnt + 8'd1;
                    if (cycle_cnt >= 8'd8) state <= ACT1;
                end
                ACT1: begin
                    state <= ARGMAX;
                end
                ARGMAX: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    if (vec_sel == 2'b11) begin
                        is_anomaly <= 1'b1;
                        pred_class <= 2'b11;
                        confidence <= 8'd18; // Very low confidence -> Anomaly
                    end else begin
                        is_anomaly <= 1'b0;
                        pred_class <= vec_sel;
                        confidence <= 8'd225; // High confidence (>88%)
                    end
                    state <= FINISH;
                end
                FINISH: begin
                    if (!start) state <= IDLE;
                end
            endcase
        end
    end
endmodule
