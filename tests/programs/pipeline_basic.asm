# Phase 7 basic pipeline program.
# This program uses manual NOPs because the Phase 7 pipeline does not yet have
# forwarding or hazard detection.

addi x1, x0, 5
nop
nop
nop
nop
addi x2, x0, 7
nop
nop
nop
nop
add x3, x1, x2
nop
nop
nop
nop
sw x3, 4(x0)
nop
nop
nop
nop
lw x4, 4(x0)
nop
nop
nop
nop
