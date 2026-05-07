# I-type ALU instruction test program.
#
# This program checks arithmetic, logical, shift, and compare instructions that
# use an immediate operand. The testbench checks x3 through x11.

addi x1, x0, 10       # x1 = 10
addi x2, x0, -16      # x2 = -16

addi x3, x1, 5        # x3 = 15
andi x4, x1, 6        # x4 = 2
ori  x5, x1, 1        # x5 = 11
xori x6, x1, 15       # x6 = 5
slli x7, x1, 2        # x7 = 40
srli x8, x1, 1        # x8 = 5
srai x9, x2, 2        # x9 = -4
slti x10, x2, 1       # x10 = 1 because -16 < 1
sltiu x11, x2, 1      # x11 = 0 because unsigned -16 is larger than 1
