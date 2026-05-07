# Full small-program instruction test.
#
# This combines upper immediate setup, arithmetic, immediate operations,
# load/store, branch, and jump behavior in one short program.

lui  x1, 0x0          # x1 = base address 0
addi x2, x0, 9        # x2 = 9
addi x3, x0, 4        # x3 = 4
add  x4, x2, x3       # x4 = 13
sw   x4, 0(x1)        # memory[0] = 13
lw   x5, 0(x1)        # x5 = 13
sub  x6, x5, x3       # x6 = 9
beq  x6, x2, branch_ok # taken because 9 == 9
addi x7, x0, 1        # skipped

branch_ok:
ori  x7, x6, 2        # x7 = 11
jal  x8, jump_ok      # x8 = 44, jump to jump_ok
addi x9, x0, 1        # skipped

jump_ok:
auipc x9, 0x0         # x9 = current PC = 48
