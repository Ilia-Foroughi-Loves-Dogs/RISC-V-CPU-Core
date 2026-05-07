# R-type ALU instruction test program.
#
# This program checks register-register arithmetic, logical, shift, and compare
# operations. The testbench checks the final values in x5 through x14.

addi x1, x0, 12       # x1 = 12
addi x2, x0, 5        # x2 = 5
addi x3, x0, -16      # x3 = -16 for arithmetic right shift and signed compare
addi x4, x0, 2        # x4 = shift amount

add  x5, x1, x2       # x5 = 17
sub  x6, x1, x2       # x6 = 7
and  x7, x1, x2       # x7 = 4
or   x8, x1, x2       # x8 = 13
xor  x9, x1, x2       # x9 = 9
sll  x10, x2, x4      # x10 = 20
srl  x11, x1, x4      # x11 = 3
sra  x12, x3, x4      # x12 = -4
slt  x13, x3, x1      # x13 = 1 because -16 < 12
sltu x14, x3, x1      # x14 = 0 because unsigned -16 is larger than 12
