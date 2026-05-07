# Upper-immediate instruction test program.
#
# This program checks that lui writes the upper immediate directly and auipc
# adds the upper immediate to the current PC.

lui   x1, 0x12345     # x1 = 0x12345000
auipc x2, 0x1         # x2 = PC + 0x1000 = 0x00001004
add   x3, x1, x2      # x3 = 0x12346004
