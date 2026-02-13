# CSE 331 — Single-Cycle MIPS Processor

## Project Overview
A single-cycle MIPS32 processor implementation in Verilog supporting all integer instructions covered in class.

## Design Specifications
- **Word size:** 32-bit
- **Architecture:** Single-cycle (each instruction completes in one clock cycle)
- **Reset:** Synchronous, active-high
- **Byte addressing:** Word-aligned instruction fetch

## Supported Instructions

### Arithmetic
- `add`, `addu`, `sub`, `subu`, `addi`, `addiu`

### Logical
- `and`, `or`, `xor`, `nor`, `andi`, `ori`, `xori`

### Shifts
- `sll`, `srl`, `sra`, `sllv`, `srlv`, `srav`

### Compare
- `slt`, `sltu`, `slti`, `sltiu`

### Move/Upper
- `lui`

### Branch
- `beq`, `bne`, `bltz`, `bgez`, `blez`, `bgtz`

### Jump
- `j`, `jal`, `jr`, `jalr`

### Memory
- `lw`, `sw`

## Project Structure
```
MIPS_Processor/
├── src/
│   ├── control/
│   │   ├── control_unit.v       # Main Decoder
│   │   └── alu_control.v        # ALU Decoder
│   │
│   ├── datapath/
│   │   ├── alu.v                # Arithmetic Logic Unit
│   │   ├── shifter.v            # Handles SLL, SRL, SRA
│   │   ├── imm_extender.v       # Sign & Zero extension
│   │   ├── add32.v              # Simple adder for PC+4 and Branch Targets
│   │   ├── mux2to1_32bit.v      # 2-to-1 MUX (32-bit)
│   │   ├── mux2to1_5bit.v       # 2-to-1 MUX (5-bit)
│   │   └── mux4to1_32bit.v      # 4-to-1 MUX for Write-Back
│   │
│   ├── memory/
│   │   ├── pc_reg.v             # Program Counter Register
│   │   ├── reg_file.v           # Register File (32 registers)
│   │   ├── imem.v               # Instruction Memory (ROM)
│   │   └── dmem.v               # Data Memory (RAM)
│   │
│   └── top/
│       └── mips_cpu.v           # Top-level CPU module
│
├── test/
│   └── mips_cpu_tb.v            # Self-checking Testbench
│
├── simulation/
│   └── prog.hex                 # Test program in hex format
│
└── README.md                    # This file
```

## Design Approach
- **Combinational logic:** Uses `assign` statements
- **Sequential logic:** Only for PC register, Register File, and Memories
- **Structural design:** Module composition with wire interconnections

## How to Run

### Simulation
1. Compile all Verilog files
2. Load test program via `$readmemh("prog.hex", ...)`
3. Run testbench
4. Check for PASS/FAIL output

### Synthesis (Quartus)
1. Create Quartus project
2. Set `mips_cpu` as top module
3. Add pin constraints if needed
4. Compile and synthesize

## Testbench Features
- Clock and reset generation
- Program load via `$readmemh`
- Self-checking assertions
- PASS/FAIL summary at end of test
- 2000 cycle timeout

## Author
CSE 331 - Computer Organization
Due Date: 24/12/2025
