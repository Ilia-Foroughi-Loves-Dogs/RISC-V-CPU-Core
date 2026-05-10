# Phase 8 load-use hazard test.
# The add depends on the preceding lw and requires one automatic stall.

addi x1, x0, 42
sw   x1, 12(x0)
lw   x2, 12(x0)
add  x3, x2, x1
sw   x3, 16(x0)
