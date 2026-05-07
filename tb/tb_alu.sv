`timescale 1ns/1ps

module tb_alu;

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

    logic [31:0] operand_a;
    logic [31:0] operand_b;
    logic [3:0]  alu_control;
    logic [31:0] result;
    logic        zero;

    alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    task automatic check(
        input logic [31:0] a,
        input logic [31:0] b,
        input logic [3:0]  control,
        input logic [31:0] expected
    );
        begin
            operand_a = a;
            operand_b = b;
            alu_control = control;
            #1;
            if (result !== expected) begin
                $error("ALU mismatch: control=%0d result=%h expected=%h", control, result, expected);
            end
            if (zero !== (expected == 32'h0000_0000)) begin
                $error("ALU zero flag mismatch for result=%h", result);
            end
        end
    endtask

    initial begin
        $display("Starting alu test");

        check(32'd10, 32'd5,  ALU_ADD,  32'd15);
        check(32'd10, 32'd10, ALU_SUB,  32'd0);
        check(32'hf0f0_0000, 32'h0ff0_0000, ALU_AND, 32'h00f0_0000);
        check(32'hf000_0000, 32'h0000_00ff, ALU_OR,  32'hf000_00ff);
        check(32'haaaa_0000, 32'hffff_0000, ALU_XOR, 32'h5555_0000);
        check(32'h0000_0001, 32'd4, ALU_SLL, 32'h0000_0010);
        check(32'h8000_0000, 32'd4, ALU_SRL, 32'h0800_0000);
        check(32'h8000_0000, 32'd4, ALU_SRA, 32'hf800_0000);
        check(32'hffff_ffff, 32'd1, ALU_SLT, 32'd1);
        check(32'hffff_ffff, 32'd1, ALU_SLTU, 32'd0);

        $display("alu test complete");
        $finish;
    end

endmodule
