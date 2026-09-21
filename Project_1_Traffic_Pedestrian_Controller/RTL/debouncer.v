// ============================================================================
// Module Name:  debouncer
// Project:      Digital Traffic & Pedestrian Signal Controller using FSM
// Target Board: AMD PYNQ-Z2
// Description:  Glitch filter and contact bounce eliminator for mechanical
//               push buttons. Uses a 2-stage synchronizer and an internal
//               counter window (approx 20 ms at 125 MHz).
//               Outputs:
//                 - btn_level: stable, debounced push-button state
//                 - btn_pulse: single 1-clock-cycle pulse on button press (rising edge)
// ============================================================================

`timescale 1ns / 1ps

module debouncer #(
    parameter COUNTER_WIDTH = 21,                 // 2^21 / 125 MHz ≈ 16.7 ms debounce time
    parameter DEBOUNCE_LIMIT = 21'd2_097_151
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  btn_level,
    output reg  btn_pulse
);

    // 2-stage synchronizer to protect against metastability
    reg sync_0;
    reg sync_1;
    always @(posedge clk) begin
        if (rst) begin
            sync_0 <= 1'b0;
            sync_1 <= 1'b0;
        end else begin
            sync_0 <= btn_in;
            sync_1 <= sync_0;
        end
    end

    // Counter-based debounce filter
    reg [COUNTER_WIDTH-1:0] counter;
    reg btn_level_prev;

    always @(posedge clk) begin
        if (rst) begin
            counter        <= {COUNTER_WIDTH{1'b0}};
            btn_level      <= 1'b0;
            btn_level_prev <= 1'b0;
            btn_pulse      <= 1'b0;
        end else begin
            btn_level_prev <= btn_level;

            if (sync_1 != btn_level) begin
                // Input differs from current output, increment filter counter
                if (counter >= DEBOUNCE_LIMIT) begin
                    btn_level <= sync_1;
                    counter   <= {COUNTER_WIDTH{1'b0}};
                end else begin
                    counter   <= counter + 1'b1;
                end
            end else begin
                // Input matches output, reset counter
                counter <= {COUNTER_WIDTH{1'b0}};
            end

            // Generate clean single-cycle pulse on rising edge of debounced signal
            btn_pulse <= (btn_level & ~btn_level_prev);
        end
    end

endmodule
