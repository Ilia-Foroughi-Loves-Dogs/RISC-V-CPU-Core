# Phase 9 taken branch test.
# The beq depends on the two immediately preceding addi instructions, so the
# branch comparator must use forwarded values.
#
# Expected final behavior:
# - x3 = 42
# - memory[20] contains 42, which is data_memory word index 5
# - the wrong-path addi x3, x0, 99 is flushed

addi x1, x0, 5
addi x2, x0, 5
beq  x1, x2, taken
addi x3, x0, 99
taken:
addi x3, x0, 42
sw   x3, 20(x0)
