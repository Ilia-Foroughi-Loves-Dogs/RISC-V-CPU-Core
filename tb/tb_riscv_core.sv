`timescale 1ns/1ps

module tb_riscv_core;

    logic        clk;
    logic        reset;
    logic [31:0] pc_debug;
    logic [31:0] instruction_debug;
    logic [31:0] alu_result_debug;
    logic [31:0] writeback_data_debug;

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
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("sim/riscv_core.vcd");
        $dumpvars(0, tb_riscv_core);
    end

    initial begin
        $display("Starting riscv_core integration test");

        reset = 1'b1;
        repeat (2) @(posedge clk);
        reset = 1'b0;

        repeat (6) begin
            @(negedge clk);
            $display("pc=%h instruction=%h alu_result=%h writeback_data=%h",
                     pc_debug, instruction_debug, alu_result_debug, writeback_data_debug);
        end

        @(posedge clk);
        #1;

        if (dut.u_data_memory.memory[0] !== 32'd12) begin
            $error("Expected data memory word 0 to contain 12, got %h",
                   dut.u_data_memory.memory[0]);
        end

        if (dut.u_register_file.registers[4] !== 32'd12) begin
            $error("Expected x4 to contain loaded value 12, got %h",
                   dut.u_register_file.registers[4]);
        end

        if (dut.u_register_file.registers[5] !== 32'd7) begin
            $error("Expected x5 to contain 7 after sub x5, x4, x1, got %h",
                   dut.u_register_file.registers[5]);
        end

        $display("riscv_core integration test complete");
        $finish;
    end

endmodule
