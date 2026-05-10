# Phase 9 jal test.
# jal writes PC + 4 to x1, jumps over the wrong-path instruction, and flushes
# that wrong-path instruction from the pipeline.
#
# Expected final behavior:
# - x1 = 4
# - x3 = 42
# - memory[28] contains 42, which is data_memory word index 7

jal  x1, target
addi x3, x0, 99
target:
addi x3, x0, 42
sw   x3, 28(x0)
