# Phase 9 not-taken branch test.
# The beq compares forwarded operands but must leave the PC on the sequential
# path because x1 and x2 are different.
#
# Expected final behavior:
# - x3 = 42
# - memory[24] contains 42, which is data_memory word index 6

addi x1, x0, 5
addi x2, x0, 7
beq  x1, x2, wrong
addi x3, x0, 42
sw   x3, 24(x0)
wrong:
addi x4, x0, 99
