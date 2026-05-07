`timescale 1ns/1ps

module tb_immediate_generator;

    localparam logic [2:0] IMM_I = 3'd0;
    localparam logic [2:0] IMM_S = 3'd1;
    localparam logic [2:0] IMM_B = 3'd2;
    localparam logic [2:0] IMM_U = 3'd3;
    localparam logic [2:0] IMM_J = 3'd4;

    logic [31:0] instruction;
    logic [2:0]  imm_src;
    logic [31:0] imm_out;

    immediate_generator dut (
        .instruction(instruction),
        .imm_src(imm_src),
        .imm_out(imm_out)
    );

    task automatic check(
        input logic [31:0] inst,
        input logic [2:0]  src,
        input logic [31:0] expected
    );
        begin
            instruction = inst;
            imm_src = src;
            #1;
            if (imm_out !== expected) begin
                $error("Immediate mismatch: src=%0d imm=%h expected=%h", src, imm_out, expected);
            end
        end
    endtask

    initial begin
        $display("Starting immediate_generator test");

        check(32'hfff0_0093, IMM_I, 32'hffff_ffff); // addi x1, x0, -1
        check(32'hfe20_2e23, IMM_S, 32'hffff_fffc); // sw x2, -4(x0)
        check(32'hfe00_0ee3, IMM_B, 32'hffff_fffc); // branch offset -4
        check(32'h1234_50b7, IMM_U, 32'h1234_5000); // lui x1, 0x12345
        check(32'h0040_006f, IMM_J, 32'h0000_0004); // jal x0, 4

        $display("immediate_generator test complete");
        $finish;
    end

endmodule
