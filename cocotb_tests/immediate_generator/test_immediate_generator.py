import cocotb
from cocotb.triggers import Timer


IMM_I = 0
IMM_S = 1
IMM_B = 2
IMM_U = 3
IMM_J = 4
MASK32 = 0xFFFF_FFFF


async def check_immediate(dut, instruction, imm_src, expected):
    dut.instruction.value = (instruction >> 7) & ((1 << 25) - 1)
    dut.imm_src.value = imm_src
    await Timer(1, unit="ns")

    actual = int(dut.imm_out.value)
    expected &= MASK32
    assert actual == expected, (
        f"imm_src {imm_src} for instruction 0x{instruction:08x} "
        f"produced 0x{actual:08x}, expected 0x{expected:08x}"
    )


@cocotb.test()
async def test_immediate_formats(dut):
    await check_immediate(dut, 0x07F0_0093, IMM_I, 0x0000_007F)
    await check_immediate(dut, 0x0640_2223, IMM_S, 0x0000_0064)
    await check_immediate(dut, 0x0000_0463, IMM_B, 0x0000_0008)
    await check_immediate(dut, 0x1234_50B7, IMM_U, 0x1234_5000)
    await check_immediate(dut, 0x0040_006F, IMM_J, 0x0000_0004)


@cocotb.test()
async def test_immediate_sign_extension(dut):
    await check_immediate(dut, 0xFFF0_0093, IMM_I, 0xFFFF_FFFF)
    await check_immediate(dut, 0xFE20_2E23, IMM_S, 0xFFFF_FFFC)
    await check_immediate(dut, 0xFE00_0EE3, IMM_B, 0xFFFF_FFFC)
    await check_immediate(dut, 0x8000_00EF, IMM_J, 0xFFF0_0000)
