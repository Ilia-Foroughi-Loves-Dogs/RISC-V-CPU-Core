# Phase 9 jalr test.
# jalr uses the value just produced in x5 as its base address, so the jump
# target calculation must use forwarding. The target address is 12, matching
# the addi x3, x0, 42 instruction below.
#
# Expected final behavior:
# - x1 = 8
# - x3 = 42
# - x5 = 12
# - memory[32] contains 42, which is data_memory word index 8

addi x5, x0, 12
jalr x1, 0(x5)
addi x3, x0, 99
addi x3, x0, 42
sw   x3, 32(x0)
