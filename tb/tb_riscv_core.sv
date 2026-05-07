`timescale 1ns/1ps

module tb_riscv_core;

    localparam int CLK_PERIOD_NS = 10;
    localparam int RESET_CYCLES  = 2;
    localparam int RUN_CYCLES    = 6;

    logic        clk;
    logic        reset;
    logic [31:0] pc_debug;
    logic [31:0] instruction_debug;
    logic [31:0] alu_result_debug;
    logic [31:0] writeback_data_debug;
    int unsigned cycle_count;
    int unsigned error_count;

    riscv_core dut (
        .clk(clk),
        .reset(reset),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .alu_result_debug(alu_result_debug),
        .writeback_data_debug(writeback_data_debug)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("sim/waves/riscv_core.vcd");
        $dumpvars(0, tb_riscv_core);
    end

    task automatic check_equal(
        input string name,
        input logic [31:0] actual,
        input logic [31:0] expected
    );
        if (actual !== expected) begin
            error_count++;
            $error("%s expected %h, got %h", name, expected, actual);
        end
    endtask

    initial begin
        cycle_count = 0;
        error_count = 0;

        $display("Starting riscv_core integration test");
        $display("Program: tests/programs/program.mem");
        $display("Waveform: sim/waves/riscv_core.vcd");
        $display("");
        $display("cycle | pc       | instruction | alu_result | writeback");
        $display("------+----------+-------------+------------+----------");

        reset = 1'b1;
        repeat (RESET_CYCLES) @(posedge clk);
        reset = 1'b0;

        repeat (RUN_CYCLES) begin
            @(negedge clk);
            $display("%5d | %08h | %08h    | %08h   | %08h",
                     cycle_count, pc_debug, instruction_debug,
                     alu_result_debug, writeback_data_debug);
            cycle_count++;
        end

        @(posedge clk);
        #1;

        check_equal("data memory word 0", dut.u_data_memory.memory[0], 32'd12);
        check_equal("x3 add result", dut.u_register_file.registers[3], 32'd12);
        check_equal("x4 load result", dut.u_register_file.registers[4], 32'd12);
        check_equal("x5 sub result", dut.u_register_file.registers[5], 32'd7);

        if (error_count == 0) begin
            $display("");
            $display("PASS: riscv_core completed %0d cycles with expected register and memory results",
                     RUN_CYCLES);
            $finish;
        end else begin
            $display("");
            $fatal(1, "FAIL: riscv_core completed with %0d error(s)", error_count);
        end
    end

endmodule
