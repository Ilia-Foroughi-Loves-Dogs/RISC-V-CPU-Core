# Default program loaded by rtl/instruction_memory.sv.
#
# For now, this duplicates basic_arithmetic.asm so existing tests can keep
# loading tests/programs/program.mem.

addi x1, x0, 5      # x1 = 5
addi x2, x0, 7      # x2 = 7
add  x3, x1, x2     # x3 = 12
sw   x3, 0(x0)      # memory[0] = 12
lw   x4, 0(x0)      # x4 = memory[0]
sub  x5, x4, x1     # x5 = 7
