# Phase 8 forwarding test.
# Dependent ALU instructions execute without manual NOPs.

addi x1, x0, 5
addi x2, x1, 3
add  x3, x2, x1
sub  x4, x3, x2
sw   x4, 8(x0)
