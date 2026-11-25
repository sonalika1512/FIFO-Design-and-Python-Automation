
This project implements an 8-bit wide, 8-depth Asynchronous FIFO using Verilog HDL.

The design supports independent write and read clock domains and uses Gray-code pointers with two-flip-flop synchronizers for Clock Domain Crossing (CDC).

Python scripts are developed to automate simulation execution, log analysis, and report generation using the Cadence Xcelium simulator.


- Design an asynchronous FIFO using synthesizable Verilog.
- Understand and implement CDC techniques.
- Implement binary and Gray-code pointer conversion.
- Generate FIFO full and empty conditions.
- Verify FIFO functionality using a Verilog testbench.
- Automate simulation and result analysis using Python.


- FIFO depth: 8 entries
- Data width: 8 bits
- Independent write and read clocks
- Binary write and read pointers
- Gray-code pointer conversion
- Two-stage synchronizers for CDC
- Full and empty flag generation
- Asynchronous reset


The design uses Gray-code pointers to transfer pointer information safely between asynchronous clock domains.

Key CDC components:

- Binary-to-Gray code conversion
- Gray-to-binary code conversion
- Two-flip-flop synchronizers
- Independent write and read pointer management
- Full and empty detection


The Verilog testbench verifies:

- Reset functionality
- FIFO write operation
- FIFO read operation
- FIFO full condition
- FIFO empty condition
- Simultaneous read and write operations
- Pointer increment and wraparound


Python scripts automate the complete simulation workflow.


- Executes the Cadence Xcelium simulator.
- Runs the Verilog RTL and testbench.
- Captures simulation output.
- Saves the simulation log.


- Reads the simulation log.
- Analyzes FIFO read operations.
- Checks FIFO full and empty detection.
- Identifies simulation results.


- Generates a simulation summary.
- Counts successful operations.
- Creates a text-based simulation report.


Executes all three scripts sequentially:

1. Simulation execution
2. Log analysis
3. Report generation

The automation flow stops if an individual script fails.


```text
async_fifo_automation/
|
|-- rtl/
|   |-- async_fifo.v
|
|-- tb/
|   |-- async_fifo_tb.v
|
|-- scripts/
|   |-- run_simulation.py
|   |-- analyze_log.py
|   |-- generate_report.py
|   |-- run_all.py
|
|-- config/
|   |-- simulation_config.json
|
|-- logs/
|   |-- simulation.log
|
|-- reports/
|   |-- fifo_simulation_report.txt
|
|-- waves/
|
|-- .gitignore
|-- README.md









