## AMD PYNQ-Z2 Master Constraints - Project 2 Environmental Sensor Node
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sys_clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sys_clk }];

set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { ack_btn }];   # BTN0
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { fault_btn }]; # BTN1
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { rst_btn }];   # BTN3

set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { sw_warn_sel }];  # SW0
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { sw_alarm_sel }]; # SW1

set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { led_level[0] }]; # LD0
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { led_level[1] }]; # LD1
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { led_level[2] }]; # LD2
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led_level[3] }]; # LD3

## RGB LED 4 (Status Alert)
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { rgb_alarm_r }]; # LD4 Red: N15
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { rgb_safe_g }];  # LD4 Green: G17
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { rgb_warn_b }];  # LD4 Blue: L15

## RGB LED 5 (Comm & Activity)
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { rgb_flt_r }];   # LD5 Red: M15
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { rgb_flt_g }];   # LD5 Green: L14

## Pmod JA (External Sensor & Buzzer)
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { sensor_sdata }]; # JA1: Data In
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { sensor_sclk }];  # JA2: Clock Out
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { buzzer_pwm }];   # JA3: Piezo Buzzer
