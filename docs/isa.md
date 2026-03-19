# Instruction Set Architecture

## Instruction Format

[ OPCODE (4 bits) | OPERAND (4 bits) ]

## Initial ISA

| Opcode | Instruction | Description |
|--------|-------------|-------------|
| 0000 | NOP | No operation |
| 0001 | LDI x | Load immediate into ACC |
| 0010 | LDA a | Load ACC from data memory |
| 0011 | STA a | Store ACC to data memory |
| 0100 | ADD a | ACC = ACC + memory[a] |
| 0101 | SUB a | ACC = ACC - memory[a] |
| 0110 | AND a | ACC = ACC & memory[a] |
| 0111 | OR a | ACC = ACC \| memory[a] |
| 1000 | XOR a | ACC = ACC ^ memory[a] |
| 1001 | NOT | Invert ACC |
| 1010 | JMP a | Jump to address |
| 1011 | JZ a | Jump if zero flag set |
| 1100 | JC a | Jump if carry flag set |
| 1101 | OUT | Output ACC |
| 1110 | HLT | Halt execution |
| 1111 | Reserved | Future extension |