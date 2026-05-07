module control_unit (
    input  logic [6:0] opcode,
    output logic       reg_write,
    output logic       alu_src,
    output logic       mem_read,
    output logic       mem_write,
    output logic       mem_to_reg,
    output logic       branch,
    output logic       jump,
    output logic       jalr,
    output logic [2:0] alu_op,
    output logic [2:0] imm_src
);

    localparam logic [6:0] OPCODE_RTYPE  = 7'b0110011;
    localparam logic [6:0] OPCODE_ITYPE  = 7'b0010011;
    localparam logic [6:0] OPCODE_LOAD   = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_JALR   = 7'b1100111;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;

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

    always_comb begin
        // Safe defaults make unsupported opcodes behave like a no-op.
        reg_write  = 1'b0;
        alu_src    = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;
        alu_op     = ALU_OP_ADD;
        imm_src    = IMM_I;

        case (opcode)
            OPCODE_RTYPE: begin
                // Register-register arithmetic and logical instructions.
                reg_write = 1'b1;
                alu_op    = ALU_OP_RTYPE;
            end
            OPCODE_ITYPE: begin
                // Register-immediate arithmetic and logical instructions.
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_ITYPE;
                imm_src   = IMM_I;
            end
            OPCODE_LOAD: begin
                // lw: compute address with base register plus I-type offset.
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = ALU_OP_ADD;
                imm_src    = IMM_I;
            end
            OPCODE_STORE: begin
                // sw: compute address with base register plus S-type offset.
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = ALU_OP_ADD;
                imm_src   = IMM_S;
            end
            OPCODE_BRANCH: begin
                // Conditional branches use register comparisons and B-type offsets.
                branch  = 1'b1;
                alu_op  = ALU_OP_BRANCH;
                imm_src = IMM_B;
            end
            OPCODE_JAL: begin
                // jal writes the link register and jumps by a J-type offset.
                reg_write = 1'b1;
                jump      = 1'b1;
                imm_src   = IMM_J;
            end
            OPCODE_JALR: begin
                // jalr writes the link register and jumps to rs1 plus an I-type offset.
                reg_write = 1'b1;
                alu_src   = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b1;
                alu_op    = ALU_OP_ADD;
                imm_src   = IMM_I;
            end
            OPCODE_LUI: begin
                // lui writes the U-type immediate value into rd.
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_LUI;
                imm_src   = IMM_U;
            end
            OPCODE_AUIPC: begin
                // auipc adds the U-type immediate to the current PC in the datapath.
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = ALU_OP_AUIPC;
                imm_src   = IMM_U;
            end
            default: begin
                // Keep safe defaults for unsupported opcodes.
            end
        endcase
    end

endmodule
