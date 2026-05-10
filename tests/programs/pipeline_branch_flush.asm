# Phase 8 branch/jump flush test.
# Wrong-path instructions after the taken branch and jump must be flushed.

addi x1, x0, 1
addi x2, x0, 1
beq  x1, x2, branch_target
addi x3, x0, 99
addi x3, x0, 88
branch_target:
addi x4, x0, 7
jal  x0, jump_target
addi x5, x0, 55
jump_target:
addi x6, x0, 9
sw   x6, 20(x0)
