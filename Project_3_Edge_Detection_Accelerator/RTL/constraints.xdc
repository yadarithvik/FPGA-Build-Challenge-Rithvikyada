## ============================================================================
## Constraints: constraints.xdc
## Project: V-SPACE FPGA Build Challenge 2026 - Experiment 3 (Intermediate)
## Title: PYNQ-Based Real-Time Edge Detection Accelerator
## Target: PYNQ-Z2 (XC7Z020-1CLG400C)
## ============================================================================

## Clock Period Definition (10.000 ns = 100 MHz System Clock)
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports clk]

## Reset (BTN3, Active-Low)
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { rst_n }];

## Status LEDs
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { status_leds[0] }]; # Processing Active (LD0)
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { status_leds[1] }]; # Edge Detected (LD1)
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { status_leds[2] }]; # Overflow (LD2)
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { status_leds[3] }]; # Accelerator Ready (LD3)
