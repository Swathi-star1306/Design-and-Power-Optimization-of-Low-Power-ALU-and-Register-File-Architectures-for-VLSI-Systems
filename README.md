# Design and Power Optimization of Low-Power ALU and Register File Architectures for VLSI Systems

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![Technology](https://img.shields.io/badge/Technology-90nm-green)
![Cadence](https://img.shields.io/badge/EDA-Cadence_Genus_&_Innovus-orange)
![Status](https://img.shields.io/badge/Status-RTL_to_GDSII-success)

---

## Abstract

Power consumption has become one of the most critical challenges in modern VLSI systems, especially in battery-operated embedded devices, IoT nodes, wearable electronics, and edge computing platforms.

This project focuses on the design, implementation, and optimization of a **Low-Power Arithmetic Logic Unit (ALU)** integrated with a **Register File** using industry-standard VLSI design methodologies.

The proposed architecture incorporates multiple low-power techniques including:

* Clock Gating
* Operand Isolation
* Activity Monitoring
* Sleep-Aware Operation

to reduce unnecessary switching activity and dynamic power consumption.

The design was implemented using **Verilog HDL** and synthesized using **Cadence Genus** with a **90nm Standard Cell Library**. Physical implementation was performed using **Cadence Innovus**, including:

* Floorplanning
* Placement
* Clock Tree Synthesis (CTS)
* Routing
* RC Extraction
* Timing Analysis
* Power Analysis

Experimental results demonstrate successful **RTL-to-GDSII implementation** with timing closure, DRC-clean routing, and significant power optimization.

---

# Objectives

* Design configurable ALU and Register File architectures
* Implement low-power optimization techniques
* Reduce switching activity and dynamic power consumption
* Compare multiple power-saving architectures
* Analyze Power, Performance, and Area (PPA)
* Perform RTL-to-GDSII ASIC implementation
* Generate ASIC-ready low-power processing subsystem

---

# System Architecture

```text
                 +-----------------------+
                 |   Control Unit        |
                 +-----------+-----------+
                             |
        ------------------------------------------------
        |                     |                        |
+-------v--------+   +--------v--------+    +---------v--------+
| Clock Gating   |   | Operand         |    | Activity Monitor |
| Controller     |   | Isolation Unit  |    | & Power Analysis |
+-------+--------+   +--------+--------+    +---------+--------+
        |                     |                        |
        ------------------------------------------------
                             |
                 +-----------v-----------+
                 |     Low-Power ALU     |
                 +-----------+-----------+
                             |
                 +-----------v-----------+
                 |    Register File      |
                 +-----------+-----------+
                             |
                 +-----------v-----------+
                 | Output/Data Interface |
                 +-----------------------+
```

---

# Low-Power Techniques Implemented

## 1️⃣ Clock Gating

Disables unnecessary clock transitions when computation is not required.

### Equation

```text
CLK_gated = CLK × Enable
```

### Benefits

* Reduced clock tree switching activity
* Lower dynamic power consumption
* Improved energy efficiency

---

## 2️⃣ Operand Isolation

Prevents inactive combinational logic from receiving unnecessary signal transitions.

### Equation

```text
X_iso = Enable × X
```

### Benefits

* Reduced combinational switching activity
* Lower dynamic power

---

## 3️⃣ Activity Monitoring

Tracks:

* Toggle Count
* Switching Activity
* Dynamic Power Estimation

---

## 4️⃣ Sleep-Aware Operation

Reduces datapath activity during idle periods.

### Benefits

* Reduced dynamic power
* Improved energy efficiency
* Enhanced low-power behavior

---

# ALU Operations Supported

| Operation | Description |
| --------- | ----------- |
| ADD       | Addition    |
| SUB       | Subtraction |
| AND       | Bitwise AND |
| OR        | Bitwise OR  |
| XOR       | Bitwise XOR |
| SLL       | Shift Left  |
| SRL       | Shift Right |
| CMP       | Comparison  |

---

# Register File Features

* Multi-register storage
* Read operation
* Write operation
* Low-power access architecture

### Register Read Equation

```text
Rout = Reg[Address]
```

---

# Design Flow

```text
RTL Design
     ↓
Functional Verification
     ↓
Logic Synthesis (Cadence Genus)
     ↓
Floorplanning
     ↓
Placement
     ↓
Clock Tree Synthesis (CTS)
     ↓
Routing
     ↓
RC Extraction
     ↓
Timing Analysis
     ↓
Power Analysis
     ↓
GDSII Generation
```

---

# Results

## Version 1 – Baseline Architecture

### Features

* Basic ALU
* Register File
* Functional Verification

| Metric       | Value        |
| ------------ | ------------ |
| Cell Count   | 262          |
| Area         | 1890.736 µm² |
| Total Power  | 0.1373 mW    |
| Timing Slack | 4.130 ns     |

### Physical Design

<img width="1916" height="1017" alt="Screenshot 2026-05-21 160232" src="https://github.com/user-attachments/assets/6effa6f9-6635-4026-91ac-7be22e112f6e" />

<img width="1244" height="895" alt="Screenshot 2026-05-22 112607" src="https://github.com/user-attachments/assets/22a73ae5-9bc2-4131-83e3-bc51fad283c7" />

<img width="1918" height="933" alt="Screenshot 2026-05-21 150425" src="https://github.com/user-attachments/assets/d43a06e3-cbbc-408d-82cc-a8ee16e1508a" />


---

## Version 2 – Optimized Architecture

### Features

* Clock Gating
* Operand Isolation
* Activity Monitoring
* Datapath Freezing

| Metric       | Value        |
| ------------ | ------------ |
| Cell Count   | 261          |
| Area         | 1983.835 µm² |
| Total Power  | 0.1233 mW    |
| Timing Slack | 6.022 ns     |

### Improvement

✅ Reduced Switching Activity

✅ Reduced Dynamic Power

✅ Improved Timing Margin

### Physical Design

<img width="1909" height="1024" alt="Screenshot 2026-05-22 112352" src="https://github.com/user-attachments/assets/edcebbfc-2642-4ffe-bcd8-53b58a0eb4b6" />

<img width="1244" height="895" alt="Screenshot 2026-05-22 112607" src="https://github.com/user-attachments/assets/1de8e46f-9eab-41ff-9d46-a7471fc22217" />

<img width="1906" height="1013" alt="Screenshot 2026-05-22 113218" src="https://github.com/user-attachments/assets/1fada550-1225-4531-995a-3fde80045788" />

---

## Version 3 – Advanced Low-Power Architecture

### Features

* Fine-Grain Clock Gating
* Operand Isolation
* Activity Counter
* Sleep-Aware Operation
* Register File Integration
* ASIC-Oriented Physical Design Flow

### Post-Route Results

| Metric              | Value     |
| ------------------- | --------- |
| Total Power         | 0.1673 mW |
| Internal Power      | 0.1168 mW |
| Switching Power     | 0.0335 mW |
| Leakage Power       | 0.0170 mW |
| WNS                 | +5.221 ns |
| TNS                 | 0         |
| Routing Overflow    | 0%        |
| Geometry Violations | 0         |

### Physical Design

#### Placement

<img width="1917" height="1014" alt="Screenshot 2026-05-26 132812" src="https://github.com/user-attachments/assets/4b2cebe5-f0af-4350-b49a-9e5328e61350" />


#### Clock Tree Synthesis

<img width="1089" height="647" alt="image" src="https://github.com/user-attachments/assets/c8bf7d8d-adda-4842-a504-6c810918880f" />


#### Final Routed Layout
<img width="1600" height="844" alt="image" src="https://github.com/user-attachments/assets/25b62f30-9d88-4a89-ac1b-a2125da486ae" />


---

# 📈 PPA Comparison

| Metric            | Version 1 | Version 2 | Version 3 |
| ----------------- | --------- | --------- | --------- |
| Cell Count        | 262       | 261       | 564       |
| Area (µm²)        | 1890.736  | 1983.835  | Increased |
| Total Power (mW)  | 0.1373    | 0.1233    | 0.1673    |
| Timing Slack (ns) | 4.130     | 6.022     | 5.221     |
| Clock Gating      | ❌         | ✅         | ✅         |
| Operand Isolation | ❌         | ✅         | ✅         |
| Activity Monitor  | ❌         | ✅         | ✅         |
| Sleep Mode        | ❌         | ❌         | ✅         |


Version 2 achieved the lowest total power, while Version 3 introduced advanced low-power functionality and complete ASIC implementation
---

# Physical Design Results

* ✔ Floorplanning Completed
* ✔ Placement Completed
* ✔ Clock Tree Synthesis Completed
* ✔ Routing Completed
* ✔ RC Extraction Completed
* ✔ Timing Closure Achieved
* ✔ Geometry Violations = 0
* ✔ Routing Overflow = 0%
* ✔ GDSII Generated

---

# Tools Used

## Front-End Design

* Verilog HDL
* NC Launch
* Cadence Xcelium

## Logic Synthesis

* Cadence Genus

## Physical Design

* Cadence Innovus

## Technology

* 90nm Standard Cell Library

---

# Applications

* Mobile Processors
* IoT Devices
* Wearable Electronics
* Edge AI Accelerators
* Automotive Electronics
* Aerospace Systems

---

# Novelty of the Project

1. Comparative Low-Power Architecture Study
2. Clock Gating Based Optimization
3. Operand Isolation Methodology
4. Activity-Aware ALU Design
5. Sleep-Aware Processing Architecture
6. Complete RTL-to-GDSII ASIC Flow
7. PPA-Oriented Design Methodology

---

# Conclusion

A low-power ALU and Register File subsystem was successfully designed and implemented using Verilog HDL and Cadence EDA tools.

The project demonstrates the effectiveness of:

* Clock Gating
* Operand Isolation
* Activity Monitoring
* Sleep-Aware Operation

in reducing switching activity while maintaining timing closure and physical design correctness.

The complete RTL-to-GDSII implementation validates the feasibility of low-power digital architectures for modern embedded and IoT applications.

---

## Author

**Swathi T**

Electronics and Communication Engineering

ASIC Physical Design | Low-Power VLSI | Digital Design
