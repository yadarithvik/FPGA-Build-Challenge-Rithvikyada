// ============================================================================
// Module Name:  traffic_fsm
// Project:      Digital Traffic & Pedestrian Signal Controller using FSM
// Target Board: AMD PYNQ-Z2 (Zynq-7000 XC7Z020-1CLG400C)
// Description:  Full-featured Synchronous Finite State Machine (FSM)
//               controlling an intersection of a Main Street, Side Street,
//               and Pedestrian Crosswalk.
//
// Key Features:
//   - 8 Deterministic States with fail-safe All-Red clearance intervals.
//   - Latching Pedestrian Crossing Request (never misses a pedestrian press).
//   - Emergency Vehicle Priority Override with safe clearance transition.
//   - Flashing Pedestrian Warning during final seconds of crossing.
//   - Real-time down-counter output (seconds remaining in current phase).
// ============================================================================

`timescale 1ns / 1ps

module traffic_fsm #(
    // Phase durations in seconds (default timing parameters)
    parameter TIME_MAIN_GREEN  = 6'd10, // Main street green duration
    parameter TIME_MAIN_YELLOW = 6'd3,  // Main street yellow duration
    parameter TIME_ALL_RED_1   = 6'd1,  // Safety clearance interval 1
    parameter TIME_SIDE_GREEN  = 6'd6,  // Side street green duration
    parameter TIME_SIDE_YELLOW = 6'd3,  // Side street yellow duration
    parameter TIME_ALL_RED_2   = 6'd1,  // Safety clearance interval 2
    parameter TIME_PED_WALK    = 6'd5   // Pedestrian crossing walk duration
)(
    input  wire       clk,                // 125 MHz system clock
    input  wire       rst,                // Synchronous active-high reset
    input  wire       sec_tick,           // 1-second pulse enable
    input  wire       blink_tick,         // 2 Hz flashing clock for pedestrian warning
    input  wire       ped_btn_pulse,      // Single pulse from debounced pedestrian button
    input  wire       emergency_pulse,    // Emergency override button pulse
    input  wire       emergency_switch,   // Emergency override persistent switch
    input  wire       side_sensor,        // Side street vehicle presence sensor

    // Light outputs: {Red, Yellow, Green}
    output reg  [2:0] main_lights,        // Main Street: [2]=Red, [1]=Yellow, [0]=Green
    output reg  [2:0] side_lights,        // Side Street: [2]=Red, [1]=Yellow, [0]=Green
    // Pedestrian outputs: [1]=Don't Walk (Red), [0]=Walk (Green)
    output reg  [1:0] ped_lights,
    
    // Status indicators
    output reg        ped_req_latched,    // High if pedestrian request is pending
    output reg        emergency_active,   // High if emergency mode is active
    output reg  [2:0] current_state,      // Current FSM state
    output reg  [5:0] seconds_remaining   // Countdown timer for current state
);

    // ========================================================================
    // FSM State Encoding (Binary 3-bit)
    // ========================================================================
    localparam [2:0]
        S0_MAIN_GREEN  = 3'd0,  // Main Green,  Side Red,    Ped Don't Walk
        S1_MAIN_YELLOW = 3'd1,  // Main Yellow, Side Red,    Ped Don't Walk
        S2_ALL_RED_1   = 3'd2,  // Main Red,    Side Red,    Ped Don't Walk (Clearance)
        S3_SIDE_GREEN  = 3'd3,  // Main Red,    Side Green,  Ped Don't Walk
        S4_SIDE_YELLOW = 3'd4,  // Main Red,    Side Yellow, Ped Don't Walk
        S5_ALL_RED_2   = 3'd5,  // Main Red,    Side Red,    Ped Don't Walk (Clearance)
        S6_PED_CROSS   = 3'd6,  // Main Red,    Side Red,    Ped WALK (Green)
        S7_EMERGENCY   = 3'd7;  // Priority Main Green corridor, Side/Ped RED

    reg [2:0] next_state;
    reg [5:0] timer_count;
    reg [5:0] current_state_duration;
    reg       emergency_latched;

    // ========================================================================
    // Emergency Request Latching Logic
    // ========================================================================
    always @(posedge clk) begin
        if (rst) begin
            emergency_latched <= 1'b0;
        end else begin
            if (emergency_pulse) begin
                emergency_latched <= ~emergency_latched; // Toggle latch on button
            end
        end
    end

    wire is_emergency = emergency_latched | emergency_switch;

    always @(posedge clk) begin
        if (rst) begin
            emergency_active <= 1'b0;
        end else begin
            emergency_active <= is_emergency;
        end
    end

    // ========================================================================
    // Pedestrian Request Latching Logic
    // ========================================================================
    always @(posedge clk) begin
        if (rst) begin
            ped_req_latched <= 1'b0;
        end else begin
            if (ped_btn_pulse && (current_state != S6_PED_CROSS)) begin
                ped_req_latched <= 1'b1; // Latch until served
            end else if (current_state == S6_PED_CROSS && timer_count >= (TIME_PED_WALK - 1'b1) && sec_tick) begin
                ped_req_latched <= 1'b0; // Clear once pedestrian phase finishes
            end
        end
    end

    // ========================================================================
    // State Duration Assignment
    // ========================================================================
    always @(*) begin
        case (current_state)
            S0_MAIN_GREEN:  current_state_duration = TIME_MAIN_GREEN;
            S1_MAIN_YELLOW: current_state_duration = TIME_MAIN_YELLOW;
            S2_ALL_RED_1:   current_state_duration = TIME_ALL_RED_1;
            S3_SIDE_GREEN:  current_state_duration = TIME_SIDE_GREEN;
            S4_SIDE_YELLOW: current_state_duration = TIME_SIDE_YELLOW;
            S5_ALL_RED_2:   current_state_duration = TIME_ALL_RED_2;
            S6_PED_CROSS:   current_state_duration = TIME_PED_WALK;
            S7_EMERGENCY:   current_state_duration = 6'd60; // Holds until cleared
            default:        current_state_duration = TIME_MAIN_GREEN;
        endcase
    end

    // ========================================================================
    // Timer Countdown Register
    // ========================================================================
    always @(posedge clk) begin
        if (rst) begin
            timer_count       <= 6'd0;
            seconds_remaining <= TIME_MAIN_GREEN;
        end else begin
            if (current_state != next_state) begin
                timer_count <= 6'd0;
                // Assign new initial countdown value for next state
                case (next_state)
                    S0_MAIN_GREEN:  seconds_remaining <= TIME_MAIN_GREEN;
                    S1_MAIN_YELLOW: seconds_remaining <= TIME_MAIN_YELLOW;
                    S2_ALL_RED_1:   seconds_remaining <= TIME_ALL_RED_1;
                    S3_SIDE_GREEN:  seconds_remaining <= TIME_SIDE_GREEN;
                    S4_SIDE_YELLOW: seconds_remaining <= TIME_SIDE_YELLOW;
                    S5_ALL_RED_2:   seconds_remaining <= TIME_ALL_RED_2;
                    S6_PED_CROSS:   seconds_remaining <= TIME_PED_WALK;
                    S7_EMERGENCY:   seconds_remaining <= 6'd0;
                    default:        seconds_remaining <= TIME_MAIN_GREEN;
                endcase
            end else if (sec_tick) begin
                timer_count <= timer_count + 1'b1;
                if (seconds_remaining > 6'd0)
                    seconds_remaining <= seconds_remaining - 1'b1;
            end
        end
    end

    // ========================================================================
    // Next-State Logic
    // ========================================================================
    always @(*) begin
        next_state = current_state;

        // Emergency Vehicle Preemption Check
        if (is_emergency) begin
            case (current_state)
                S0_MAIN_GREEN, S7_EMERGENCY: begin
                    next_state = S7_EMERGENCY; // Direct hold on priority green
                end
                S1_MAIN_YELLOW: begin
                    // Let yellow finish safely, then go to emergency
                    if (sec_tick && (timer_count >= TIME_MAIN_YELLOW - 1'b1))
                        next_state = S7_EMERGENCY;
else
                        next_state = S1_MAIN_YELLOW;
                end
                S3_SIDE_GREEN: begin
                    // Transition side green immediately to yellow for clearance!
                    next_state = S4_SIDE_YELLOW;
                end
                S4_SIDE_YELLOW: begin
                    if (sec_tick && (timer_count >= TIME_SIDE_YELLOW - 1'b1))
                        next_state = S7_EMERGENCY;
else
                        next_state = S4_SIDE_YELLOW;
                end
                S6_PED_CROSS: begin
                    // Clearance from pedestrian to emergency
                    if (sec_tick && (timer_count >= 2)) // Abbreviated safe pedestrian clear
                        next_state = S7_EMERGENCY;
else
                        next_state = S6_PED_CROSS;
                end
                default: begin
                    next_state = S7_EMERGENCY;
                end
            endcase
        end else begin
            // Normal Operating Cycle
            case (current_state)
                S0_MAIN_GREEN: begin
                    // Stay green for minimum time, then transition if side/pedestrian demand exists
                    if (sec_tick && (timer_count >= TIME_MAIN_GREEN - 1'b1)) begin
                        // Advance to yellow if pedestrian request or side street car detected (or periodic)
                        if (ped_req_latched || side_sensor || 1'b1)
                            next_state = S1_MAIN_YELLOW;
                    end
                end

                S1_MAIN_YELLOW: begin
                    if (sec_tick && (timer_count >= TIME_MAIN_YELLOW - 1'b1))
                        next_state = S2_ALL_RED_1;
                end

                S2_ALL_RED_1: begin
                    if (sec_tick && (timer_count >= TIME_ALL_RED_1 - 1'b1)) begin
                        // Priority to pedestrian if pending, otherwise side street
                        if (ped_req_latched)
                            next_state = S6_PED_CROSS;
else
                            next_state = S3_SIDE_GREEN;
                    end
                end

                S6_PED_CROSS: begin
                    if (sec_tick && (timer_count >= TIME_PED_WALK - 1'b1))
                        next_state = S3_SIDE_GREEN; // After pedestrian crosses, serve side street
                end

                S3_SIDE_GREEN: begin
                    if (sec_tick && (timer_count >= TIME_SIDE_GREEN - 1'b1))
                        next_state = S4_SIDE_YELLOW;
                end

                S4_SIDE_YELLOW: begin
                    if (sec_tick && (timer_count >= TIME_SIDE_YELLOW - 1'b1))
                        next_state = S5_ALL_RED_2;
                end

                S5_ALL_RED_2: begin
                    if (sec_tick && (timer_count >= TIME_ALL_RED_2 - 1'b1))
                        next_state = S0_MAIN_GREEN; // Return to Main Street
                end

                S7_EMERGENCY: begin
                    if (!is_emergency)
                        next_state = S0_MAIN_GREEN; // Resume normal Main Green
                end

                default: begin
                    next_state = S0_MAIN_GREEN;
                end
            endcase
        end
    end

    // ========================================================================
    // State Register (Sequential Logic)
    // ========================================================================
    always @(posedge clk) begin
        if (rst) begin
            current_state <= S0_MAIN_GREEN;
        end else begin
            current_state <= next_state;
        end
    end

    // ========================================================================
    // Output Logic (Moore and Registered Outputs)
    // Light format: [2]=Red, [1]=Yellow, [0]=Green
    // Ped format:   [1]=Don't Walk (Red), [0]=Walk (Green)
    // ========================================================================
    always @(*) begin
        case (current_state)
            S0_MAIN_GREEN: begin
                main_lights = 3'b001; // Main Green
                side_lights = 3'b100; // Side Red
                ped_lights  = 2'b10;  // Ped Don't Walk (Red)
            end

            S1_MAIN_YELLOW: begin
                main_lights = 3'b010; // Main Yellow
                side_lights = 3'b100; // Side Red
                ped_lights  = 2'b10;  // Ped Don't Walk (Red)
            end

            S2_ALL_RED_1: begin
                main_lights = 3'b100; // Main Red
                side_lights = 3'b100; // Side Red
                ped_lights  = 2'b10;  // Ped Don't Walk (Red)
            end

            S6_PED_CROSS: begin
                main_lights = 3'b100; // Main Red
                side_lights = 3'b100; // Side Red
                // During last 2 seconds of pedestrian crossing, flash Green/Red for warning
                if (seconds_remaining <= 6'd2) begin
                    ped_lights = blink_tick ? 2'b01 : 2'b10; // Flash Walk/Don't Walk
                end else begin
                    ped_lights = 2'b01; // Solid Green WALK
                end
            end

            S3_SIDE_GREEN: begin
                main_lights = 3'b100; // Main Red
                side_lights = 3'b001; // Side Green
                ped_lights  = 2'b10;  // Ped Don't Walk (Red)
            end

            S4_SIDE_YELLOW: begin
                main_lights = 3'b100; // Main Red
                side_lights = 3'b010; // Side Yellow
                ped_lights  = 2'b10;  // Ped Don't Walk (Red)
            end

            S5_ALL_RED_2: begin
                main_lights = 3'b100; // Main Red
                side_lights = 3'b100; // Side Red
                ped_lights  = 2'b10;  // Ped Don't Walk (Red)
            end

            S7_EMERGENCY: begin
                main_lights = 3'b001; // Priority Corridor: Main Green
                side_lights = 3'b100; // Side Red
                ped_lights  = 2'b10;  // Ped Don't Walk (Red)
            end

            default: begin
                main_lights = 3'b100; // Fail-safe: All Red
                side_lights = 3'b100;
                ped_lights  = 2'b10;
            end
        endcase
    end

endmodule
