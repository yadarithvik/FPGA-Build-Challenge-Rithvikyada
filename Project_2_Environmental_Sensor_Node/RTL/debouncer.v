// ============================================================================
// File: debouncer.v
// Project: GPIO-Based Environmental Sensor Node
// Target: AMD PYNQ-Z2 (XC7Z020-1CLG400C)
// ============================================================================
`timescale 1ns / 1ps

module debouncer (
    input  wire clk,
    input  wire btn_in,
    output reg  btn_out
);
    reg [17:0] counter;
    reg sync_0, sync_1;

`ifdef SIMULATION
    localparam [17:0] DEB_LIMIT = 18'd4;
`else
    // 250,000 cycles at 125 MHz = 2 ms hardware debounce window
    localparam [17:0] DEB_LIMIT = 18'd250000;
`endif

    initial begin
        counter = 18'd0;
        sync_0  = 1'b0;
        sync_1  = 1'b0;
        btn_out = 1'b0;
    end

    always @(posedge clk) begin
        sync_0 <= btn_in;
        sync_1 <= sync_0;
        if (sync_1 == btn_out) begin
            counter <= 18'd0;
        end else begin
            counter <= counter + 18'd1;
            if (counter >= DEB_LIMIT) begin
                btn_out <= sync_1;
                counter <= 18'd0;
            end
        end
    end
endmodule
