## ============================================================================
## Master Constraints File (XDC) for AMD PYNQ-Z2
## Project: Digital Traffic & Pedestrian Signal Controller using FSM
## Target:  xc7z020clg400-1
## ============================================================================

## ----------------------------------------------------------------------------
## 125 MHz Clock Signal
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sysclk }];
create_clock -add -name sys_clk_pin -period 8.000 -waveform {0 4.000} [get_ports { sysclk }];

## ----------------------------------------------------------------------------
## Push Buttons
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { btn[0] }]; # Pedestrian Request
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { btn[1] }]; # Emergency Trigger
set_property -dict { PACKAGE_PIN L20   IOSTANDARD LVCMOS33 } [get_ports { btn[2] }]; # Side Vehicle Sensor
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { btn[3] }]; # System Master Reset

## ----------------------------------------------------------------------------
## Slide Switches
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }];  # Emergency Persistent Mode
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }];  # Fast Demo Speedup (100x)

## ----------------------------------------------------------------------------
## Single-Color Onboard User LEDs (Main Street & Status)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; # Main Street GREEN
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; # Main Street YELLOW
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; # Main Street RED
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; # Ped Request Pending

## ----------------------------------------------------------------------------
## RGB LED 4 (Side Street Traffic Light)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { rgb_led4_r }]; # Side RED / Amber
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { rgb_led4_g }]; # Side GREEN / Amber
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { rgb_led4_b }]; # Side BLUE

## ----------------------------------------------------------------------------
## RGB LED 5 (Pedestrian Crosswalk Signal)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { rgb_led5_r }]; # Ped DON'T WALK (Red)
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { rgb_led5_g }]; # Ped WALK (Green)
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { rgb_led5_b }]; # Ped BLUE

## ----------------------------------------------------------------------------
## Pmod JA Header (Pins 1-4 & 7-10 for External Breadboard Traffic Lights)
## ----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { pmodja[0] }]; # JA1:  Main Red
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { pmodja[1] }]; # JA2:  Main Yellow
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { pmodja[2] }]; # JA3:  Main Green
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { pmodja[3] }]; # JA4:  Ped Walk (Green)
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { pmodja[4] }]; # JA7:  Side Red
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { pmodja[5] }]; # JA8:  Side Yellow
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { pmodja[6] }]; # JA9:  Side Green
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { pmodja[7] }]; # JA10: Ped Don't Walk (Red)
