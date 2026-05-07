# Jump instruction test program.
#
# jal and jalr should both write link registers and redirect the PC. The
# skipped instructions write failing values that should be bypassed.

jal  x1, after_jal    # x1 = 4, jump to after_jal
addi x5, x0, 1        # skipped by jal

after_jal:
addi x5, x0, 55       # x5 = 55
addi x6, x0, 24       # x6 = byte address of after_jalr
jalr x2, x6, 0        # x2 = 20, jump to after_jalr
addi x7, x0, 1        # skipped by jalr

after_jalr:
addi x7, x0, 77       # x7 = 77
