module alu_formal;
    localparam logic [3:0] ALU_ADD  = 4'd0;
    localparam logic [3:0] ALU_SUB  = 4'd1;
    localparam logic [3:0] ALU_AND  = 4'd2;
    localparam logic [3:0] ALU_OR   = 4'd3;
    localparam logic [3:0] ALU_XOR  = 4'd4;
    localparam logic [3:0] ALU_SLT  = 4'd8;
    localparam logic [3:0] ALU_SLTU = 4'd9;

    (* anyseq *) logic [31:0] operand_a;
    (* anyseq *) logic [31:0] operand_b;
    (* anyseq *) logic [3:0]  alu_control;
    logic [31:0] result;
    logic        zero;

    alu dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    always_comb begin
        if (alu_control == ALU_ADD) begin
            assert(result == operand_a + operand_b);
        end

        if (alu_control == ALU_SUB) begin
            assert(result == operand_a - operand_b);
        end

        if (alu_control == ALU_AND) begin
            assert(result == (operand_a & operand_b));
        end

        if (alu_control == ALU_OR) begin
            assert(result == (operand_a | operand_b));
        end

        if (alu_control == ALU_XOR) begin
            assert(result == (operand_a ^ operand_b));
        end

        if (alu_control == ALU_SLT) begin
            assert(result == (($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0));
        end

        if (alu_control == ALU_SLTU) begin
            assert(result == ((operand_a < operand_b) ? 32'd1 : 32'd0));
        end

        assert(zero == (result == 32'h0000_0000));
    end
endmodule
