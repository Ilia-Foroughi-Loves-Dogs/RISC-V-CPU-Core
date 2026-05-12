import cocotb
from cocotb.triggers import Timer


MASK32 = 0xFFFF_FFFF

ALU_ADD = 0
ALU_SUB = 1
ALU_AND = 2
ALU_OR = 3
ALU_XOR = 4
ALU_SLL = 5
ALU_SRL = 6
ALU_SRA = 7
ALU_SLT = 8
ALU_SLTU = 9


def signed32(value):
    value &= MASK32
    return value - (1 << 32) if value & 0x8000_0000 else value


async def check_alu(dut, operand_a, operand_b, control, expected):
    dut.operand_a.value = operand_a & MASK32
    dut.operand_b.value = operand_b & MASK32
    dut.alu_control.value = control
    await Timer(1, unit="ns")

    actual = int(dut.result.value)
    expected &= MASK32
    assert actual == expected, (
        f"ALU control {control} with a=0x{operand_a & MASK32:08x} "
        f"b=0x{operand_b & MASK32:08x} produced 0x{actual:08x}, "
        f"expected 0x{expected:08x}"
    )

    expected_zero = 1 if expected == 0 else 0
    actual_zero = int(dut.zero.value)
    assert actual_zero == expected_zero, (
        f"zero flag was {actual_zero}, expected {expected_zero} "
        f"for result 0x{expected:08x}"
    )


@cocotb.test()
async def test_alu_operations(dut):
    await check_alu(dut, 0x0000_0005, 0x0000_0007, ALU_ADD, 0x0000_000C)
    await check_alu(dut, 0x0000_0005, 0x0000_0007, ALU_SUB, 0xFFFF_FFFE)
    await check_alu(dut, 0xF0F0_00FF, 0x0FF0_F0F0, ALU_AND, 0x00F0_00F0)
    await check_alu(dut, 0xF0F0_00FF, 0x0FF0_F0F0, ALU_OR, 0xFFF0_F0FF)
    await check_alu(dut, 0xF0F0_00FF, 0x0FF0_F0F0, ALU_XOR, 0xFF00_F00F)
    await check_alu(dut, 0x0000_0001, 0x0000_0004, ALU_SLL, 0x0000_0010)
    await check_alu(dut, 0x8000_0000, 0x0000_001F, ALU_SRL, 0x0000_0001)
    await check_alu(dut, 0x8000_0000, 0x0000_001F, ALU_SRA, 0xFFFF_FFFF)
    await check_alu(dut, 0xFFFF_FFFF, 0x0000_0001, ALU_SLT, 0x0000_0001)
    await check_alu(dut, 0xFFFF_FFFF, 0x0000_0001, ALU_SLTU, 0x0000_0000)


@cocotb.test()
async def test_alu_zero_flag(dut):
    await check_alu(dut, 0x1234_5678, 0x1234_5678, ALU_SUB, 0x0000_0000)
    await check_alu(dut, 0x0000_0001, 0x0000_0001, ALU_ADD, 0x0000_0002)


@cocotb.test()
async def test_alu_signed_and_unsigned_comparisons(dut):
    cases = [
        (0x8000_0000, 0x0000_0001),
        (0x7FFF_FFFF, 0x8000_0000),
        (0xFFFF_FFFE, 0xFFFF_FFFF),
    ]

    for operand_a, operand_b in cases:
        signed_expected = 1 if signed32(operand_a) < signed32(operand_b) else 0
        unsigned_expected = 1 if (operand_a & MASK32) < (operand_b & MASK32) else 0
        await check_alu(dut, operand_a, operand_b, ALU_SLT, signed_expected)
        await check_alu(dut, operand_a, operand_b, ALU_SLTU, unsigned_expected)
