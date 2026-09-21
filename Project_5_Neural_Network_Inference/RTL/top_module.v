// ============================================================================
// File: top_module.v
// Project: FPGA-Accelerated Lightweight Neural Network Inference for Real-Time Object/Anomaly Detection
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// Team: TEAM BVD-26 (Yada Rithvik, Neelkorak Jana, Anirudh Dodia)
// ============================================================================
`timescale 1ns / 1ps

module top_module (
    input  wire        sys_clk,       // 125 MHz onboard oscillator (Pin H16)
    input  wire        rst_btn,       // BTN3: Master synchronous reset
    input  wire        trigger_btn,   // BTN0: Single-shot inference trigger
    input  wire        stream_btn,    // BTN1: Continuous inference streaming mode
    input  wire        sw_vec0,       // SW0: Input feature vector select bit 0
    input  wire        sw_vec1,       // SW1: Input feature vector select bit 1
    output wire [3:0]  led_class,     // LD0-LD3: 4-bit winning class index / confidence
    output wire        rgb_infer_act, // LD4 Green: Inference active strobe (<10 us)
    output wire        rgb_infer_done,// LD4 Blue: Inference calculation complete
    output wire        rgb_class_g,   // LD5 Green: Normal class verified (High confidence)
    output wire        rgb_anomaly_r  // LD5 Red: Anomaly / Outlier pattern detected
);

    wire rst, trig_clean, stream_clean;
    wire [1:0] test_vector_sel;
    wire [1:0] pred_class;
    wire [7:0] confidence_score;
    wire is_anomaly, infer_busy, infer_done;

    debouncer db_rst    (.clk(sys_clk), .btn_in(rst_btn),     .btn_out(rst));
    debouncer db_trig   (.clk(sys_clk), .btn_in(trigger_btn), .btn_out(trig_clean));
    debouncer db_stream (.clk(sys_clk), .btn_in(stream_btn),  .btn_out(stream_clean));

    assign test_vector_sel = {sw_vec1, sw_vec0};

    // Neural Network Accelerator Core (INT8 Quantized MLP/CNN)
    nn_accelerator_top nn_core (
        .clk(sys_clk),
        .rst(rst),
        .start(trig_clean | stream_clean),
        .vec_sel(test_vector_sel),
        .pred_class(pred_class),
        .confidence(confidence_score),
        .is_anomaly(is_anomaly),
        .busy(infer_busy),
        .done(infer_done)
    );

    assign led_class      = {is_anomaly, 1'b0, pred_class};
    assign rgb_infer_act  = infer_busy;
    assign rgb_infer_done = infer_done;
    assign rgb_class_g    = (!is_anomaly && infer_done);
    assign rgb_anomaly_r  = (is_anomaly && infer_done);

endmodule
