`timescale 1ns/1ps

module tb_riscv_core;

    localparam int CLK_PERIOD_NS = 10;
    localparam int RESET_CYCLES  = 2;
    localparam int DEFAULT_RUN_CYCLES = 40;

    logic        clk;
    logic        reset;
    logic [31:0] pc_debug;
    logic [31:0] instruction_debug;
    logic [31:0] alu_result_debug;
    logic [31:0] writeback_data_debug;
    int unsigned cycle_count;
    int unsigned error_count;
    int unsigned run_cycles;
    string       program_path;

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

    task automatic check_default_program;
        begin
            check_equal("data memory word 0", dut.u_data_memory.memory[0], 32'd12);
            check_equal("x3 add result", dut.u_register_file.registers[3], 32'd12);
            check_equal("x4 load result", dut.u_register_file.registers[4], 32'd12);
            check_equal("x5 sub result", dut.u_register_file.registers[5], 32'd7);
        end
    endtask

    task automatic check_program_results;
        begin
            if ($test$plusargs("CHECK_ALU")) begin
                check_equal("x5 add",  dut.u_register_file.registers[5],  32'd17);
                check_equal("x6 sub",  dut.u_register_file.registers[6],  32'd7);
                check_equal("x7 and",  dut.u_register_file.registers[7],  32'd4);
                check_equal("x8 or",   dut.u_register_file.registers[8],  32'd13);
                check_equal("x9 xor",  dut.u_register_file.registers[9],  32'd9);
                check_equal("x10 sll", dut.u_register_file.registers[10], 32'd20);
                check_equal("x11 srl", dut.u_register_file.registers[11], 32'd3);
                check_equal("x12 sra", dut.u_register_file.registers[12], 32'hffff_fffc);
                check_equal("x13 slt", dut.u_register_file.registers[13], 32'd1);
                check_equal("x14 sltu", dut.u_register_file.registers[14], 32'd0);
            end else if ($test$plusargs("CHECK_IMMEDIATE")) begin
                check_equal("x3 addi",  dut.u_register_file.registers[3],  32'd15);
                check_equal("x4 andi",  dut.u_register_file.registers[4],  32'd2);
                check_equal("x5 ori",   dut.u_register_file.registers[5],  32'd11);
                check_equal("x6 xori",  dut.u_register_file.registers[6],  32'd5);
                check_equal("x7 slli",  dut.u_register_file.registers[7],  32'd40);
                check_equal("x8 srli",  dut.u_register_file.registers[8],  32'd5);
                check_equal("x9 srai",  dut.u_register_file.registers[9],  32'hffff_fffc);
                check_equal("x10 slti", dut.u_register_file.registers[10], 32'd1);
                check_equal("x11 sltiu", dut.u_register_file.registers[11], 32'd0);
            end else if ($test$plusargs("CHECK_LOAD_STORE")) begin
                check_equal("data memory word 0", dut.u_data_memory.memory[0], 32'd42);
                check_equal("data memory word 1", dut.u_data_memory.memory[1], 32'hffff_fff9);
                check_equal("x2 lw word 0", dut.u_register_file.registers[2], 32'd42);
                check_equal("x4 lw word 1", dut.u_register_file.registers[4], 32'hffff_fff9);
                check_equal("x5 add loaded values", dut.u_register_file.registers[5], 32'd35);
            end else if ($test$plusargs("CHECK_BRANCH")) begin
                check_equal("x10 beq path", dut.u_register_file.registers[10], 32'd11);
                check_equal("x11 bne path", dut.u_register_file.registers[11], 32'd22);
                check_equal("x12 blt path", dut.u_register_file.registers[12], 32'd33);
                check_equal("x13 bge path", dut.u_register_file.registers[13], 32'd44);
            end else if ($test$plusargs("CHECK_JUMP")) begin
                check_equal("x1 jal link", dut.u_register_file.registers[1], 32'd4);
                check_equal("x2 jalr link", dut.u_register_file.registers[2], 32'd20);
                check_equal("x5 jal target", dut.u_register_file.registers[5], 32'd55);
                check_equal("x6 jalr target base", dut.u_register_file.registers[6], 32'd24);
                check_equal("x7 jalr target", dut.u_register_file.registers[7], 32'd77);
            end else if ($test$plusargs("CHECK_UPPER")) begin
                check_equal("x1 lui", dut.u_register_file.registers[1], 32'h1234_5000);
                check_equal("x2 auipc", dut.u_register_file.registers[2], 32'h0000_1004);
                check_equal("x3 upper add", dut.u_register_file.registers[3], 32'h1234_6004);
            end else if ($test$plusargs("CHECK_FULL")) begin
                check_equal("x4 arithmetic result", dut.u_register_file.registers[4], 32'd13);
                check_equal("data memory word 0", dut.u_data_memory.memory[0], 32'd13);
                check_equal("x5 load result", dut.u_register_file.registers[5], 32'd13);
                check_equal("x6 subtract result", dut.u_register_file.registers[6], 32'd9);
                check_equal("x7 branch/immediate result", dut.u_register_file.registers[7], 32'd11);
                check_equal("x8 jal link", dut.u_register_file.registers[8], 32'd44);
                check_equal("x9 auipc target", dut.u_register_file.registers[9], 32'd48);
            end else if ($test$plusargs("CHECK_NONE")) begin
                $display("Final self-checks disabled for %s", program_path);
            end else begin
                check_default_program();
            end
        end
    endtask

    initial begin
        cycle_count = 0;
        error_count = 0;
        run_cycles = DEFAULT_RUN_CYCLES;
        program_path = "tests/programs/program.mem";

        if (!$value$plusargs("PROGRAM=%s", program_path)) begin
            program_path = "tests/programs/program.mem";
        end

        if (!$value$plusargs("CYCLES=%d", run_cycles)) begin
            run_cycles = DEFAULT_RUN_CYCLES;
        end

        $display("Starting riscv_core integration test");
        $display("Program: %s", program_path);
        $display("Run cycles: %0d", run_cycles);
        $display("Waveform: sim/waves/riscv_core.vcd");
        $display("");
        $display("cycle | pc       | instruction | alu_result | writeback");
        $display("------+----------+-------------+------------+----------");

        reset = 1'b1;
        repeat (RESET_CYCLES) @(posedge clk);
        reset = 1'b0;

        repeat (run_cycles) begin
            @(negedge clk);
            $display("%5d | %08h | %08h    | %08h   | %08h",
                     cycle_count, pc_debug, instruction_debug,
                     alu_result_debug, writeback_data_debug);
            cycle_count++;
        end

        @(posedge clk);
        #1;

        check_program_results();

        if (error_count == 0) begin
            $display("");
            $display("PASS: riscv_core completed %0d cycles with expected register and memory results",
                     run_cycles);
            $finish;
        end else begin
            $display("");
            $fatal(1, "FAIL: riscv_core completed with %0d error(s)", error_count);
        end
    end

endmodule
