# Load/store instruction test program.
#
# This program stores two words into data memory and loads them back. The
# testbench checks data memory words 0 and 1 plus the loaded register values.

addi x1, x0, 42       # x1 = 42
sw   x1, 0(x0)        # memory[0] = 42
lw   x2, 0(x0)        # x2 = memory[0]

addi x3, x0, -7       # x3 = -7
sw   x3, 4(x0)        # memory[1] = -7
lw   x4, 4(x0)        # x4 = memory[1]

add  x5, x2, x4       # x5 = 35
