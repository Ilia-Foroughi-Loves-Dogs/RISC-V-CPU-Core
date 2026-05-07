# Basic arithmetic and memory program for the single-cycle RV32I core.
#
# This hand-written program is used by the integrated CPU testbench. The
# matching machine-code file is basic_arithmetic.mem, with one 32-bit
# instruction word per line in hexadecimal.
#
# Expected behavior:
# - x1 = 5
# - x2 = 7
# - x3 = x1 + x2 = 12
# - memory[0] = 12
# - x4 = memory[0] = 12
# - x5 = x4 - x1 = 7

addi x1, x0, 5      # x1 = 5
addi x2, x0, 7      # x2 = 7
add  x3, x1, x2     # x3 = 12
sw   x3, 0(x0)      # memory[0] = 12
lw   x4, 0(x0)      # x4 = memory[0]
sub  x5, x4, x1     # x5 = 7
