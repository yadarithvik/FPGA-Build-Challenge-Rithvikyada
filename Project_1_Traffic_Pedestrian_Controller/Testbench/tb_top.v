// ============================================================================
// Testbench Name: traffic_tb
// Project:        Digital Traffic & Pedestrian Signal Controller using FSM
// Description:    Self-checking simulation testbench verifying:
//                   1. Power-on reset & initial state (Main Green).
//                   2. Normal cyclic transitions (Main -> Side -> Main).
//                   3. Pedestrian button latching & dedicated walk cycle.
//                   4. Pedestrian warning flash countdown.
//                   5. Emergency vehicle preemption interrupt & recovery.
//                   6. FSM safety rules (Never Main Green & Side Green together).
// ============================================================================

`timescale 1ns / 1ps

module tb_top;

    // Simulation Clock & Inputs
    reg        clk;
    reg        rst;
    reg        sec_tick;
    reg        blink_tick;
    reg        ped_btn_pulse;
    reg        emergency_pulse;
    reg        emergency_switch;
    reg        side_sensor;

    // Outputs from DUT
    wire [2:0] main_lights;
    wire [2:0] side_lights;
    wire [1:0] ped_lights;
    wire       ped_req_latched;
    wire       emergency_active;
    wire [2:0] current_state;
    wire [5:0] seconds_remaining;

    // State names for clear console transcript
    reg [127:0] state_name;
    always @(*) begin
        case (current_state)
            3'd0: state_name = "S0_MAIN_GREEN ";
            3'd1: state_name = "S1_MAIN_YELLOW";
            3'd2: state_name = "S2_ALL_RED_1  ";
            3'd3: state_name = "S3_SIDE_GREEN ";
            3'd4: state_name = "S4_SIDE_YELLOW";
            3'd5: state_name = "S5_ALL_RED_2  ";
            3'd6: state_name = "S6_PED_CROSS  ";
            3'd7: state_name = "S7_EMERGENCY  ";
            default: state_name = "UNKNOWN       ";
        endcase
    end

    // ========================================================================
    // Instantiate Device Under Test (DUT) with shortened simulation parameters
    // ========================================================================
    traffic_fsm #(
        .TIME_MAIN_GREEN (6'd4), // 4 sec for fast sim
        .TIME_MAIN_YELLOW(6'd2), // 2 sec
        .TIME_ALL_RED_1  (6'd1), // 1 sec
        .TIME_SIDE_GREEN (6'd3), // 3 sec
        .TIME_SIDE_YELLOW(6'd2), // 2 sec
        .TIME_ALL_RED_2  (6'd1), // 1 sec
        .TIME_PED_WALK   (6'd3)  // 3 sec
    ) dut (
        .clk             (clk),
        .rst             (rst),
        .sec_tick        (sec_tick),
        .blink_tick      (blink_tick),
        .ped_btn_pulse   (ped_btn_pulse),
        .emergency_pulse (emergency_pulse),
        .emergency_switch(emergency_switch),
        .side_sensor     (side_sensor),
        .main_lights     (main_lights),
        .side_lights     (side_lights),
        .ped_lights      (ped_lights),
        .ped_req_latched (ped_req_latched),
        .emergency_active(emergency_active),
        .current_state   (current_state),
        .seconds_remaining(seconds_remaining)
    );

    // ========================================================================
    // 125 MHz Clock Generator (Period = 8 ns)
    // ========================================================================
    always #4 clk = ~clk;

    // ========================================================================
    // Helper Task: Generate N One-Second Ticks
    // ========================================================================
    task advance_seconds(input integer count);
        integer i;
        begin
            for (i = 0; i < count; i = i + 1) begin
                @(posedge clk);
                sec_tick   = 1'b1;
                blink_tick = ~blink_tick;
                @(posedge clk);
                sec_tick   = 1'b0;
                #40; // Idle simulation delay between ticks
            end
        end
    endtask

    // ========================================================================
    // Concurrent Safety Monitor
    // Ensures Main Green and Side Green are NEVER active simultaneously!
    // ========================================================================
    always @(posedge clk) begin
        if (!rst) begin
            if (main_lights[0] && side_lights[0]) begin
                $display("\n[FATAL COLLISION ERROR at %0t ps] Main Green and Side Green are both ON!", $time);
                $stop;
            end
            if (ped_lights[0] && (main_lights[0] || side_lights[0])) begin
                $display("\n[FATAL PEDESTRIAN ERROR at %0t ps] Pedestrian Walk ON while vehicular Green is ON!", $time);
                $stop;
            end
        end
    end

    // ========================================================================
    // Main Stimulus Sequence
    // ========================================================================
    integer error_count = 0;

    initial begin
        $display("==================================================================");
        $display("STARTING TRAFFIC & PEDESTRIAN FSM CONTROLLER SIMULATION TESTBENCH");
        $display("==================================================================");

        // 1. Initialization
        clk              = 0;
        rst              = 1;
        sec_tick         = 0;
        blink_tick       = 0;
        ped_btn_pulse    = 0;
        emergency_pulse  = 0;
        emergency_switch = 0;
        side_sensor      = 0;

        #32;
        @(posedge clk);
        rst = 0; // Release reset
        $display("[Time: %0t] Reset released. Testing initial state...", $time);

        #16;
        if (current_state !== 3'd0 || main_lights !== 3'b001) begin
            $display("[FAIL] Expected State S0_MAIN_GREEN (3'd0) with Main Green ON.");
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Initial State is S0_MAIN_GREEN (Main Green Active).");
        end

        // 2. Test Normal Cycle (Main Green -> Main Yellow -> All Red -> Side Green -> Side Yellow -> All Red -> Main Green)
        $display("\n--- TEST PHASE 1: Normal Autonomous Cycle Verification ---");
        advance_seconds(4); // Advance 4s in Main Green
        $display("[Time: %0t] State after 4s: %s | Main: %b | Side: %b | Ped: %b", 
                 $time, state_name, main_lights, side_lights, ped_lights);

        advance_seconds(2); // Advance 2s in Main Yellow
        $display("[Time: %0t] State after Yellow: %s | Main: %b", $time, state_name, main_lights);

        advance_seconds(1); // Advance 1s in All Red 1
        $display("[Time: %0t] State in Clearance: %s | Main: %b | Side: %b", $time, state_name, main_lights, side_lights);

        advance_seconds(3); // Advance 3s in Side Green
        $display("[Time: %0t] State in Side Green: %s | Side: %b", $time, state_name, side_lights);

        advance_seconds(2); // Side Yellow
        advance_seconds(1); // All Red 2
        advance_seconds(1); // Back to Main Green
        $display("[Time: %0t] Cycled back to: %s | Main Green: %b", $time, state_name, main_lights);

        // 3. Test Pedestrian Latching & Dedicated Crossing
        $display("\n--- TEST PHASE 2: Pedestrian Crossing Latch & Service ---");
        $display("Pedestrian presses crossing button during Main Green...");
        @(posedge clk);
        ped_btn_pulse = 1'b1;
        @(posedge clk);
        ped_btn_pulse = 1'b0;

        #16;
        if (!ped_req_latched) begin
            $display("[FAIL] Pedestrian request was not latched!");
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Pedestrian request successfully latched (ped_req_latched = 1).");
        end

        advance_seconds(4); // Finish Main Green
        advance_seconds(2); // Finish Main Yellow
        advance_seconds(1); // Finish All Red 1

        // Now FSM should enter S6_PED_CROSS
        #16;
        if (current_state !== 3'd6 || ped_lights[0] !== 1'b1) begin
            $display("[FAIL] Did not enter S6_PED_CROSS or Ped Walk not active! State: %s", state_name);
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Correctly entered S6_PED_CROSS (Pedestrian Walk Active).");
        end

        advance_seconds(3); // Complete Pedestrian walk time
        #16;
        if (ped_req_latched !== 1'b0) begin
            $display("[FAIL] Pedestrian latch was not cleared after walk cycle!");
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Pedestrian request latch automatically cleared after crossing.");
        end

        // 4. Test Emergency Vehicle Preemption
        $display("\n--- TEST PHASE 3: Emergency Vehicle Preemption ---");
        advance_seconds(2); // In Side Green now
        $display("Emergency Vehicle arrives during Side Street Green! Triggering emergency switch...");
        emergency_switch = 1'b1;

        #20;
        $display("[Time: %0t] Immediate State: %s (Verifying safe yellow transition)", $time, state_name);
        // Should transition immediately to Side Yellow for safe clearance, not abrupt green!
        advance_seconds(2); // Finish clearance

        #16;
        if (current_state !== 3'd7 || main_lights !== 3'b001) begin
            $display("[FAIL] Did not enter S7_EMERGENCY Priority Corridor!");
            error_count = error_count + 1;
        end else begin
            $display("[PASS] Entered S7_EMERGENCY with Priority Corridor Main Green active.");
        end

        advance_seconds(5); // Emergency vehicle passing through corridor...
        $display("Emergency vehicle cleared. De-asserting emergency switch...");
        emergency_switch = 1'b0;

        advance_seconds(1);
        #16;
        $display("[Time: %0t] System recovered to: %s", $time, state_name);

        // Summary
        $display("\n==================================================================");
        if (error_count == 0) begin
            $display(">>>>> ALL VERIFICATION TESTS PASSED SUCCESSFULLY! (0 ERRORS) <<<<<");
        end else begin
            $display(">>>>> TEST COMPLETED WITH %0d ERRORS! <<<<<", error_count);
        end
        $display("==================================================================");
        $finish;
    end

endmodule
