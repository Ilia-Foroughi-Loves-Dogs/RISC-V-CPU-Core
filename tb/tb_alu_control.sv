`timescale 1ns/1ps

module tb_alu_control;

    localparam logic [2:0] ALU_OP_ADD    = 3'd0;
    localparam logic [2:0] ALU_OP_BRANCH = 3'd1;
    localparam logic [2:0] ALU_OP_RTYPE  = 3'd2;
    localparam logic [2:0] ALU_OP_ITYPE  = 3'd3;

    localparam logic [3:0] ALU_ADD  = 4'd0;
    localparam logic [3:0] ALU_SUB  = 4'd1;
    localparam logic [3:0] ALU_AND  = 4'd2;
    localparam logic [3:0] ALU_OR   = 4'd3;
    localparam logic [3:0] ALU_XOR  = 4'd4;
    localparam logic [3:0] ALU_SLL  = 4'd5;
    localparam logic [3:0] ALU_SRL  = 4'd6;
    localparam logic [3:0] ALU_SRA  = 4'd7;
    localparam logic [3:0] ALU_SLT  = 4'd8;
    localparam logic [3:0] ALU_SLTU = 4'd9;

    logic [2:0] alu_op;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [3:0] alu_control;

    alu_control dut (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control)
    );

    task automatic check(
        input logic [2:0] op,
        input logic [2:0] f3,
        input logic [6:0] f7,
        input logic [3:0] expected
    );
        begin
            alu_op = op;
            funct3 = f3;
            funct7 = f7;
            #1;
            if (alu_control !== expected) begin
                $error("ALU control mismatch: op=%0d f3=%b f7=%b got=%0d expected=%0d",
                       op, f3, f7, alu_control, expected);
            end
        end
    endtask

    initial begin
        $display("Starting alu_control test");

        check(ALU_OP_ADD,    3'b000, 7'b0000000, ALU_ADD);
        check(ALU_OP_RTYPE,  3'b000, 7'b0000000, ALU_ADD);
        check(ALU_OP_RTYPE,  3'b000, 7'b0100000, ALU_SUB);
        check(ALU_OP_RTYPE,  3'b111, 7'b0000000, ALU_AND);
        check(ALU_OP_RTYPE,  3'b110, 7'b0000000, ALU_OR);
        check(ALU_OP_RTYPE,  3'b100, 7'b0000000, ALU_XOR);
        check(ALU_OP_RTYPE,  3'b001, 7'b0000000, ALU_SLL);
        check(ALU_OP_RTYPE,  3'b101, 7'b0000000, ALU_SRL);
        check(ALU_OP_RTYPE,  3'b101, 7'b0100000, ALU_SRA);
        check(ALU_OP_RTYPE,  3'b010, 7'b0000000, ALU_SLT);
        check(ALU_OP_RTYPE,  3'b011, 7'b0000000, ALU_SLTU);
        check(ALU_OP_ITYPE,  3'b000, 7'b0000000, ALU_ADD);
        check(ALU_OP_ITYPE,  3'b101, 7'b0100000, ALU_SRA);
        check(ALU_OP_BRANCH, 3'b000, 7'b0000000, ALU_SUB);
        check(ALU_OP_BRANCH, 3'b100, 7'b0000000, ALU_SLT);

        $display("alu_control test complete");
        $finish;
    end

endmodule
