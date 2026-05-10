`timescale 1ns/1ps

module tb_riscv_pipelined_core;

    localparam int CLK_PERIOD_NS = 10;
    localparam int RESET_CYCLES  = 2;
    localparam int RUN_CYCLES    = 60;

    logic        clk;
    logic        reset;
    logic [31:0] if_pc_debug;
    logic [31:0] id_instruction_debug;
    logic [31:0] ex_alu_result_debug;
    logic [31:0] mem_alu_result_debug;
    logic [31:0] wb_writeback_data_debug;
    logic        stall_debug;
    logic        flush_debug;
    logic [1:0]  forward_a_debug;
    logic [1:0]  forward_b_debug;
    int unsigned cycle_count;
    int unsigned error_count;
    string       program_path;

    riscv_pipelined_core dut (
        .clk(clk),
        .reset(reset),
        .if_pc_debug(if_pc_debug),
        .id_instruction_debug(id_instruction_debug),
        .ex_alu_result_debug(ex_alu_result_debug),
        .mem_alu_result_debug(mem_alu_result_debug),
        .wb_writeback_data_debug(wb_writeback_data_debug),
        .stall_debug(stall_debug),
        .flush_debug(flush_debug),
        .forward_a_debug(forward_a_debug),
        .forward_b_debug(forward_b_debug)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("sim/waves/riscv_pipelined_core.vcd");
        $dumpvars(0, tb_riscv_pipelined_core);
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
        program_path = "tests/programs/pipeline_basic.mem";

        if (!$value$plusargs("PROGRAM=%s", program_path)) begin
            program_path = "tests/programs/pipeline_basic.mem";
        end

        $display("Starting riscv_pipelined_core test");
        $display("Program: %s", program_path);
        $display("Waveform: sim/waves/riscv_pipelined_core.vcd");
        $display("");
        $display("cycle | if_pc    | id_instr  | ex_alu   | mem_alu  | wb_data  | st | fl | fa | fb");
        $display("------+----------+-----------+----------+----------+----------+----+----+----+---");

        reset = 1'b1;
        repeat (RESET_CYCLES) @(posedge clk);
        reset = 1'b0;

        repeat (RUN_CYCLES) begin
            @(negedge clk);
            $display("%5d | %08h | %08h  | %08h | %08h | %08h | %1b  | %1b  | %02b | %02b",
                     cycle_count, if_pc_debug, id_instruction_debug,
                     ex_alu_result_debug, mem_alu_result_debug,
                     wb_writeback_data_debug, stall_debug, flush_debug,
                     forward_a_debug, forward_b_debug);
            cycle_count++;
        end

        @(posedge clk);
        #1;

        if (program_path == "tests/programs/pipeline_forwarding.mem") begin
            check_equal("x1 forwarding result", dut.u_register_file.registers[1], 32'd5);
            check_equal("x2 forwarded addi result", dut.u_register_file.registers[2], 32'd8);
            check_equal("x3 forwarded add result", dut.u_register_file.registers[3], 32'd13);
            check_equal("x4 forwarded sub result", dut.u_register_file.registers[4], 32'd5);
            check_equal("forwarding store word 2", dut.u_data_memory.memory[2], 32'd5);
        end else if (program_path == "tests/programs/pipeline_load_use.mem") begin
            check_equal("x1 load-use setup", dut.u_register_file.registers[1], 32'd42);
            check_equal("x2 loaded value", dut.u_register_file.registers[2], 32'd42);
            check_equal("x3 load-use add result", dut.u_register_file.registers[3], 32'd84);
            check_equal("load-use store word 4", dut.u_data_memory.memory[4], 32'd84);
        end else if (program_path == "tests/programs/pipeline_branch_flush.mem") begin
            check_equal("x1 branch operand", dut.u_register_file.registers[1], 32'd1);
            check_equal("x2 branch operand", dut.u_register_file.registers[2], 32'd1);
            check_equal("x3 wrong-path branch writes flushed", dut.u_register_file.registers[3], 32'd0);
            check_equal("x4 branch target result", dut.u_register_file.registers[4], 32'd7);
            check_equal("x5 wrong-path jump write flushed", dut.u_register_file.registers[5], 32'd0);
            check_equal("x6 jump target result", dut.u_register_file.registers[6], 32'd9);
            check_equal("branch flush store word 5", dut.u_data_memory.memory[5], 32'd9);
        end else begin
            check_equal("x1 addi result", dut.u_register_file.registers[1], 32'd5);
            check_equal("x2 addi result", dut.u_register_file.registers[2], 32'd7);
            check_equal("x3 add result", dut.u_register_file.registers[3], 32'd12);
            check_equal("data memory word 1", dut.u_data_memory.memory[1], 32'd12);
            check_equal("x4 load result", dut.u_register_file.registers[4], 32'd12);
        end

        if (error_count == 0) begin
            $display("");
            $display("PASS: riscv_pipelined_core completed %0d cycles with expected results",
                     RUN_CYCLES);
            $finish;
        end else begin
            $display("");
            $fatal(1, "FAIL: riscv_pipelined_core completed with %0d error(s)", error_count);
        end
    end

endmodule
