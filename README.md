# RISC-V Processor in Verilog

Two implementations of a 64-bit RISC-V processor: a **single-cycle sequential** design and a **5-stage pipelined** design with hazard handling. Both run the same instruction subset and are verified in simulation with waveform dumps.

Built for the Introduction to Processor Architecture course (Spring 2025), IIIT Hyderabad, by Team 9: Aryan Shrivastava, Prakhar Gupta, and Somish Singh Nol. The full design write-up, with waveforms for each stage, is in [`report.pdf`](report.pdf), and the assignment brief is in [`IPA_Project_2025.pdf`](IPA_Project_2025.pdf).

## Supported instructions

`add`, `sub`, `and`, `or`, `ld`, `sd`, `beq`: R-type ALU operations, 64-bit loads and stores, and conditional branches.

## Designs

### Sequential (`sequential/`)

A single-cycle datapath: instruction fetch, register read, ALU, data memory, and write-back all complete in one clock. Modules: program counter and next-address logic, instruction memory, control unit, ALU control and ALU, immediate generator, register file, and data memory.

### Pipelined (`pipelined/`)

A classic 5-stage pipeline (IF, ID, EX, MEM, WB) with pipeline registers between stages.

| Hazard | Handling |
| --- | --- |
| Data (ALU result needed by the next instructions) | Forwarding unit (`forwarding.v`) bypasses results from EX/MEM and MEM/WB |
| Load-use | Hazard detection (`hazard_control.v`) stalls one cycle, then forwards the loaded value |
| Control (`beq`) | Branches are predicted not taken; on a taken branch, IF/ID and ID/EX are flushed and fetch restarts at the target |

## Running the simulation

Each design reads its program from `instructions.txt` and its initial data memory from `data_data.txt` (binary, one word per line).

```bash
cd pipelined/src            # or sequential/src
iverilog -o sim main_testbench.v
vvp sim                     # writes gtk.vcd
gtkwave gtk.vcd waveform.gtkw
```

## My contributions

- **Sequential:** connected the fetch and decode stages, wrote the immediate generator, and created the instruction and data test programs.
- **Pipelined:** built the IF and ID stages with their pipeline registers.
