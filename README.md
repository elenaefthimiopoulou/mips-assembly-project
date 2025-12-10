# MIPS Assembly Assignment

An implementation of algorithmic routines and low-level data manipulation written in **MIPS Assembly**, developed for the **Computer Systems Organization** course at Athens University of Economics and Business (AUEB).

## Overview
- Low-level algorithm implementation directly targeting the MIPS architecture.
- Efficient register usage and memory alignment.
- Stack frame handling for function calls and procedure conventions (`jal`, `jr`).
- Interaction with the runtime environment using MIPS system calls (`syscall`).

## Structure
- `src/assignment1.s`: The primary MIPS assembly source code.

## Execution & Simulation
The program is designed to be assembled and executed using the **MARS** (MIPS Assembler and Runtime Simulator) or **SPIM** simulator.

1. Launch **MARS** (or run `java -jar Mars.jar`).
2. Open `src/assignment1.s`.
3. Assemble the source code (`F3` or **Run -> Assemble**).
4. Run the program (`F5` or **Run -> Go**) or step through instructions to inspect register and memory states.