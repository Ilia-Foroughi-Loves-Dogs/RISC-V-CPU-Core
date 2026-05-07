`timescale 1ns/1ps

module tb_control_unit;

    localparam logic [2:0] ALU_OP_ADD    = 3'd0;
    localparam logic [2:0] ALU_OP_BRANCH = 3'd1;
    localparam logic [2:0] ALU_OP_RTYPE  = 3'd2;
    localparam logic [2:0] ALU_OP_ITYPE  = 3'd3;
    localparam logic [2:0] ALU_OP_LUI    = 3'd4;
    localparam logic [2:0] ALU_OP_AUIPC  = 3'd5;

    localparam logic [2:0] IMM_I = 3'd0;
    localparam logic [2:0] IMM_S = 3'd1;
    localparam logic [2:0] IMM_B = 3'd2;
    localparam logic [2:0] IMM_U = 3'd3;
    localparam logic [2:0] IMM_J = 3'd4;

    logic [6:0] opcode;
    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;
    logic       jump;
    logic       jalr;
    logic [2:0] alu_op;
    logic [2:0] imm_src;

    control_unit dut (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .alu_op(alu_op),
        .imm_src(imm_src)
    );

    task automatic check(
        input logic [6:0] op,
        input logic       exp_reg_write,
        input logic       exp_alu_src,
        input logic       exp_mem_read,
        input logic       exp_mem_write,
        input logic       exp_mem_to_reg,
        input logic       exp_branch,
        input logic       exp_jump,
        input logic       exp_jalr,
        input logic [2:0] exp_alu_op,
        input logic [2:0] exp_imm_src
    );
        begin
            opcode = op;
            #1;
            if ({reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, jump, jalr} !==
                {exp_reg_write, exp_alu_src, exp_mem_read, exp_mem_write, exp_mem_to_reg, exp_branch, exp_jump, exp_jalr}) begin
                $error("Control bits mismatch for opcode %b", op);
            end
            if (alu_op !== exp_alu_op) $error("alu_op mismatch for opcode %b", op);
            if (imm_src !== exp_imm_src) $error("imm_src mismatch for opcode %b", op);
        end
    endtask

    initial begin
        $display("Starting control_unit test");

        check(7'b0110011, 1, 0, 0, 0, 0, 0, 0, 0, ALU_OP_RTYPE,  IMM_I);
        check(7'b0010011, 1, 1, 0, 0, 0, 0, 0, 0, ALU_OP_ITYPE,  IMM_I);
        check(7'b0000011, 1, 1, 1, 0, 1, 0, 0, 0, ALU_OP_ADD,    IMM_I);
        check(7'b0100011, 0, 1, 0, 1, 0, 0, 0, 0, ALU_OP_ADD,    IMM_S);
        check(7'b1100011, 0, 0, 0, 0, 0, 1, 0, 0, ALU_OP_BRANCH, IMM_B);
        check(7'b1101111, 1, 0, 0, 0, 0, 0, 1, 0, ALU_OP_ADD,    IMM_J);
        check(7'b1100111, 1, 1, 0, 0, 0, 0, 1, 1, ALU_OP_ADD,    IMM_I);
        check(7'b0110111, 1, 1, 0, 0, 0, 0, 0, 0, ALU_OP_LUI,    IMM_U);
        check(7'b0010111, 1, 1, 0, 0, 0, 0, 0, 0, ALU_OP_AUIPC,  IMM_U);
        check(7'b0000000, 0, 0, 0, 0, 0, 0, 0, 0, ALU_OP_ADD,    IMM_I);

        $display("control_unit test complete");
        $finish;
    end

endmodule
