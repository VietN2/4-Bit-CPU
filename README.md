# 4-Bit CPU in Verilog

A 4-bit accumulator-based CPU I designed and built from scratch in Verilog. It has a 15-instruction ISA, a multi-cycle control unit, and runs verified in simulation using Icarus Verilog.

**Status:** ✅ Working — CPU executes test programs and produces correct output

---

## Table of Contents

- [Architecture](#architecture)
- [Instruction Set](#instruction-set)
- [Modules](#modules)
- [How to Run](#how-to-run)
- [Test Program](#test-program)
- [Simulation Output](#simulation-output)
- [Design Decisions](#design-decisions)
- [Project Structure](#project-structure)
- [Tools](#tools)
- [What I Learned](#what-i-learned)

---

## Architecture

| Property | Value |
|----------|-------|
| Data Width | 4 bits |
| Instruction Width | 8 bits (4-bit opcode + 4-bit operand) |
| Architecture | Accumulator-based |
| Execution | Multi-cycle (FETCH → DECODE → EXECUTE) |
| Instruction Memory | 16 × 8-bit ROM |
| Data Memory | 16 × 4-bit RAM |
| Registers | ACC, IR, PC |
| Flags | Zero, Carry |

<!-- TODO: Add datapath diagram -->

---

## Instruction Set

Instructions are 8 bits: `[OPCODE (4 bits) | OPERAND (4 bits)]`

| Opcode | Mnemonic | Description |
|--------|----------|-------------|
| `0000` | NOP | No operation |
| `0001` | LDI x | Load immediate x into ACC |
| `0010` | LDA a | Load ACC from memory[a] |
| `0011` | STA a | Store ACC to memory[a] |
| `0100` | ADD a | ACC = ACC + memory[a] |
| `0101` | SUB a | ACC = ACC - memory[a] |
| `0110` | AND a | ACC = ACC & memory[a] |
| `0111` | OR a | ACC = ACC \| memory[a] |
| `1000` | XOR a | ACC = ACC ^ memory[a] |
| `1001` | NOT | ACC = ~ACC |
| `1010` | JMP a | Jump to address a |
| `1011` | JZ a | Jump if zero flag set |
| `1100` | JC a | Jump if carry flag set |
| `1101` | OUT | Output ACC |
| `1110` | HLT | Halt CPU |

---

## Modules

7 modules wired together in `cpu_top.v`:

| Module | File | What it does |
|--------|------|-------------|
| ALU | `rtl/alu.v` | ADD, SUB, AND, OR, XOR, NOT + zero/carry flags |
| Program Counter | `rtl/pc.v` | Tracks current instruction address, supports jumps |
| Register | `rtl/register.v` | 4-bit accumulator with write enable |
| Instruction Memory | `rtl/instr_mem.v` | 16×8 ROM, loads `.mem` files |
| Data Memory | `rtl/data_mem.v` | 16×4 RAM, combinational read, synchronous write |
| Control Unit | `rtl/control_unit.v` | FSM that decodes opcodes and drives control signals |
| CPU Top | `rtl/cpu_top.v` | Wires everything together + IR + ACC input mux |

---

## How to Run

You need [Icarus Verilog](http://iverilog.icarus.com/) installed. Run from the project root:

**ALU testbench:**
```bash
iverilog -o alu_test rtl/alu.v tb/alu_tb.v
vvp alu_test
```

**Full CPU:**
```bash
iverilog -o cpu_test rtl/alu.v rtl/pc.v rtl/register.v rtl/instr_mem.v rtl/data_mem.v rtl/control_unit.v rtl/cpu_top.v tb/cpu_tb.v
vvp cpu_test
```

---

## Test Program

`programs/test1.mem` — basic arithmetic:

```
LDI 3       → ACC = 3
STA 0       → store 3 at memory[0]
LDI 2       → ACC = 2
ADD 0       → ACC = 2 + memory[0] = 5
OUT         → output ACC
HLT         → stop
```

Expected output: `0101` (5)

---

## Simulation Output

### ALU Tests

Tested all 6 operations plus carry/zero edge cases:

```
Time  A     B     OP   RESULT ZERO CARRY
0     0011  0010  000  0101    0    0     ← 3+2=5
10000 0101  0011  001  0010    0    0     ← 5-3=2
20000 0110  0011  010  0010    0    0     ← 6&3=2
30000 0110  0011  011  0111    0    0     ← 6|3=7
40000 0110  0011  100  0101    0    0     ← 6^3=5
50000 0110  0000  101  1001    0    0     ← ~6=9
60000 0010  0010  001  0000    1    0     ← 2-2=0 (zero)
70000 1111  0001  000  0000    1    1     ← 15+1 overflow (carry)
80000 0010  0101  001  1101    0    1     ← 2-5 underflow (carry)
90000 0000  0000  000  0000    1    0     ← 0+0=0 (zero)
```

### Full CPU

```
Output: 0101 (5)
```

CPU runs the test program and outputs the correct result. ✅

---

## Design Decisions

**Why multi-cycle?** A single-cycle design would have been simpler, but multi-cycle better shows how a real CPU steps through instruction stages. It also let me build a proper FSM for the control unit, which was the most challenging part of the project.

**Control signal bug I found:** During testing, the CPU was outputting 0 instead of 5. I used `$monitor` to trace signals cycle by cycle and found that `acc_wr` (the accumulator write enable) was staying high from the previous instruction into the next FETCH cycle. This caused the accumulator to get overwritten with the wrong value during STA. The fix was clearing all control signals at the start of FETCH so they only stay active for one cycle.

**Why the IR matters:** Without an instruction register, the instruction changes the moment the PC increments during FETCH. That means DECODE and EXECUTE end up looking at the next instruction instead of the current one. Latching the instruction into an IR during FETCH keeps it stable through all three states.

**ACC input mux:** The accumulator can receive data from three places — immediate values, data memory, or the ALU. A 2-bit `acc_src` signal picks which one through a mux in `cpu_top.v`. This keeps the control unit simple since it just sets signals instead of moving data around.

---

## Project Structure

```
4-Bit-CPU/
├── rtl/                # Verilog modules
│   ├── alu.v
│   ├── pc.v
│   ├── register.v
│   ├── instr_mem.v
│   ├── data_mem.v
│   ├── control_unit.v
│   └── cpu_top.v
├── tb/                 # Testbenches
│   ├── alu_tb.v
│   └── cpu_tb.v
├── programs/           # Machine code (.mem files)
│   └── test1.mem
├── docs/               # Documentation
│   ├── isa.md
│   ├── project-specs.md
│   └── testing.md
├── .gitignore
└── README.md
```

---

## Tools

- Verilog
- Icarus Verilog
- GTKWave
- Git / GitHub
- VS Code

---

## What I Learned

This was my first time building a complete digital system from architecture to working simulation. Some things that stuck:

- **FSM bugs are subtle.** The control signal latching issue didn't show up as a compile error or an obvious failure — the CPU just silently gave the wrong answer. Finding it required tracing signals with `$monitor` and thinking about what should happen on each clock cycle. It taught me that simulation and debugging are just as important as writing the code.

- **Building one module at a time works.** I built and tested each module independently before wiring them together. When the full CPU didn't work on the first try, I already knew each piece was correct, so the problem had to be in the wiring or the control signals. That narrowed the debugging a lot.

- **The top module should just be wiring.** `cpu_top.v` has no logic in it — it just connects modules with wires and a mux. Keeping it structural made it much easier to see how data flows through the CPU.

- **Edge cases catch real bugs.** The ALU passed basic tests right away, but it was the carry edge cases (15+1, 2-5) that proved the flags actually worked correctly.