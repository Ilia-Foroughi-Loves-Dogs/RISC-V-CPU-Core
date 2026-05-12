import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


MASK32 = 0xFFFF_FFFF


async def reset_dut(dut):
    dut.reset.value = 1
    dut.reg_write.value = 0
    dut.rs1.value = 0
    dut.rs2.value = 0
    dut.rd.value = 0
    dut.write_data.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    dut.reset.value = 0
    await Timer(1, unit="ns")


async def write_reg(dut, reg, value):
    dut.rd.value = reg
    dut.write_data.value = value & MASK32
    dut.reg_write.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, unit="ns")
    dut.reg_write.value = 0
    dut.rd.value = 0
    dut.write_data.value = 0
    await Timer(1, unit="ns")


async def check_reads(dut, rs1, expected1, rs2, expected2):
    dut.rs1.value = rs1
    dut.rs2.value = rs2
    await Timer(1, unit="ns")

    actual1 = int(dut.read_data1.value)
    actual2 = int(dut.read_data2.value)
    assert actual1 == (expected1 & MASK32), (
        f"rs1 x{rs1} read 0x{actual1:08x}, expected 0x{expected1 & MASK32:08x}"
    )
    assert actual2 == (expected2 & MASK32), (
        f"rs2 x{rs2} read 0x{actual2:08x}, expected 0x{expected2 & MASK32:08x}"
    )


@cocotb.test()
async def test_reset_clears_registers(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    for reg in range(32):
        await check_reads(dut, reg, 0, reg, 0)


@cocotb.test()
async def test_write_read_and_two_read_ports(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    await write_reg(dut, 5, 0x1234_5678)
    await write_reg(dut, 6, 0xCAFE_BABE)
    await check_reads(dut, 5, 0x1234_5678, 6, 0xCAFE_BABE)


@cocotb.test()
async def test_x0_is_hardwired_to_zero(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())
    await reset_dut(dut)

    await write_reg(dut, 0, 0xFFFF_FFFF)
    await check_reads(dut, 0, 0, 0, 0)

    await write_reg(dut, 1, 0x0000_0001)
    await check_reads(dut, 0, 0, 1, 0x0000_0001)
