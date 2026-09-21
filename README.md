# V-SPACE FPGA Build Challenge 2026
## Official Competition Submission Repository

---

## 👥 Team Information

- **Team Name**: **TEAM BVD-26**
- **Team Leader**: Yada Rithvik (Reg No: `26BVD0190`)
- **Team Members**:
  - Member 1 (Team Leader): **Yada Rithvik** (Reg No: `26BVD0190`)
  - Member 2: **Neelkorak Jana** (Reg No: `26BVD0113`)
  - Member 3: **Anirudh Dodia** (Reg No: `26BVD0100`)
- **Institution**: Vellore Institute of Technology (VIT), Vellore
- **Selected FPGA Board**: **AMD PYNQ-Z2** (Xilinx Zynq-7000 SoC `XC7Z020-1CLG400C`)

---

## 🎯 Project Summary

This repository contains the complete design, implementation, simulation, and verification files for the experiments undertaken as part of the **V-SPACE FPGA Build Challenge 2026** during **graVITas '26**.

| Experiment | Category | Project Title & Description | Status |

| **Experiment 1** | Beginner | **Digital Traffic & Pedestrian Signal Controller using FSM on Zynq Programmable Logic**: Real-time 8-state Moore/Mealy FSM with pedestrian latching, 2 Hz warning flasher, fail-safe All-Red clearance, and emergency vehicle preemption. | **Completed & Verified** ✅ |
| **Experiment 2** | Beginner | **GPIO-Based Environmental Sensor Node with Real-Time Threshold Alerts**: Synchronous sampling of external sensor lines with configurable digital filter thresholds and alert triggers. |  **Completed & Verified** ✅  |
| **Experiment 3** | Intermediate | **PYNQ-Based Real-Time Edge Detection Accelerator**: Hardware Sobel/Prewitt 2D spatial convolution accelerator with AXI stream DMAs benchmarked against software OpenCV. |  **Completed & Verified** ✅ |
| **Experiment 4** | Intermediate | **FPGA-Accelerated Real-Time ECG Signal Anomaly Detection System**: DSP-based QRS detection pipeline running on Zynq PL for arrhythmia identification. |  **Completed & Verified** ✅  |
| **Experiment 5** | Advanced | **FPGA-Accelerated Lightweight Neural Network Inference for Real-Time Object/Anomaly Detection**: Quantized CNN/MLP inference core with AXI memory streaming on PYNQ-Z2. |  **Completed & Verified** ✅  |

---

## 🛠️ FPGA Board Specifications

- **Development Board**: AMD PYNQ-Z2
- **FPGA SoC**: Xilinx Zynq-7000 SoC (`XC7Z020-1CLG400C`)
- **Processing System (PS)**: Dual-core ARM Cortex-A9 MPCore @ 650 MHz
- **Programmable Logic (PL)**:
  - Artix-7 Equivalent FPGA Fabric
  - 53,200 Look-Up Tables (LUTs)
  - 106,400 Flip-Flops (FFs)
  - 140 Block RAMs (36 Kb each, 4.9 Mb total)
  - 220 DSP48E1 Slices
- **Clock Source**: 125 MHz onboard oscillator (`Pin H16`)
- **Onboard I/O Resources Used in Experiment 1**:
  - 4 User LEDs (`LD0`–`LD3`) for Main Street signaling and Pedestrian Status
  - 2 RGB LEDs (`LD4`–`LD5`) for Side Street and Pedestrian Crosswalk signals
  - 4 Push Buttons (`BTN0`–`BTN3`) for Pedestrian Request, Emergency, Sensor & Master Reset
  - 2 Slide Switches (`SW0`–`SW1`) for Persistent Emergency Mode & 100x Demo Speedup

---

## 📁 Repository Structure

```
FPGA-Build-Challenge-TeamName/
│
├── README.md                          # Repository Home & Team Information
│
├── Experiment-1-Beginner/             # Complete Submission for Project 1
│   ├── Documentation/
│   │   ├── Experiment-1_Report.md     # Markdown Technical Report
│   │   ├── Experiment-1_Report.html   # Standalone HTML Technical Report
│   │   └── Experiment-1_Report.pdf    # Official Submission PDF Report
│   ├── RTL/
│   │   ├── top_module.v               # Top-Level Verilog Module
│   │   ├── traffic_fsm.v              # Core 8-State FSM
│   │   ├── clock_divider.v            # 125 MHz to 1 Hz Divider & 2 Hz Flasher
│   │   ├── debouncer.v                # Glitch-Free Button Filter
│   │   └── constraints.xdc            # Master PYNQ-Z2 Constraints (XDC)
│   ├── Testbench/
│   │   └── tb_top.v                   # Self-Checking Simulation Testbench
│   ├── Simulation/
│   │   ├── waveform.png               # High-Resolution Waveform Capture
│   │   ├── transcript.txt             # Simulation Log Output
│   │   └── simulation_report.pdf      # PDF Simulation Report
│   ├── Images/
│   │   ├── block_diagram.png          # System Architecture Diagram
│   │   ├── rtl_schematic.png          # RTL Interconnection Schematic
│   │   ├── board_setup.jpg            # Physical Board Setup Diagram
│   │   └── hardware_output.jpg        # Active Hardware State Capture
│   └── Video_Link.txt                 # Demonstration Video Script & Link
│
├── Experiment-2-Beginner/
├── Experiment-3-Intermediate/
├── Experiment-4-Intermediate/
├── Experiment-5-Advanced/
└── Final_Report/
    └── TeamName_Final_Report.pdf
```
