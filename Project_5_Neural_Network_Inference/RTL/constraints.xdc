## AMD PYNQ-Z2 Master Constraints - Project 5 Neural Network Inference Accelerator
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sys_clk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sys_clk }];

set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { trigger_btn }]; # BTN0
set_property -dict { PACKAGE_PIN D20   IOSTANDARD LVCMOS33 } [get_ports { stream_btn }];  # BTN1
set_property -dict { PACKAGE_PIN L19   IOSTANDARD LVCMOS33 } [get_ports { rst_btn }];     # BTN3

set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVCMOS33 } [get_ports { sw_vec0 }]; # SW0
set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVCMOS33 } [get_ports { sw_vec1 }]; # SW1

set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33 } [get_ports { led_class[0] }]; # LD0
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { led_class[1] }]; # LD1
set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { led_class[2] }]; # LD2
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led_class[3] }]; # LD3

## RGB LED 4 (Inference Engine Status)
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { rgb_infer_act }];  # LD4 Green: G17 (Active)
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { rgb_infer_done }]; # LD4 Blue: L15 (Complete)

## RGB LED 5 (Classification Result)
set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { rgb_class_g }];    # LD5 Green: L14 (Normal)
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { rgb_anomaly_r }];  # LD5 Red: M15 (Anomaly)
