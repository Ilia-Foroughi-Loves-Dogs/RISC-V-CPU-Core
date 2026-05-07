# Branch instruction test program.
#
# Each branch is expected to be taken and skip a failing write. The following
# instruction writes the expected marker value.

addi x1, x0, 5        # x1 = 5
addi x2, x0, 5        # x2 = 5
addi x3, x0, 7        # x3 = 7
addi x4, x0, -1       # x4 = -1

beq  x1, x2, beq_ok   # taken because 5 == 5
addi x10, x0, 1       # skipped
beq_ok:
addi x10, x0, 11      # x10 = 11

bne  x1, x3, bne_ok   # taken because 5 != 7
addi x11, x0, 1       # skipped
bne_ok:
addi x11, x0, 22      # x11 = 22

blt  x4, x1, blt_ok   # taken because -1 < 5
addi x12, x0, 1       # skipped
blt_ok:
addi x12, x0, 33      # x12 = 33

bge  x3, x1, bge_ok   # taken because 7 >= 5
addi x13, x0, 1       # skipped
bge_ok:
addi x13, x0, 44      # x13 = 44
