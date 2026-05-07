module alu_control (
    input  logic [2:0] alu_op,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [3:0] alu_control
);

    localparam logic [2:0] ALU_OP_ADD    = 3'd0;
    localparam logic [2:0] ALU_OP_BRANCH = 3'd1;
    localparam logic [2:0] ALU_OP_RTYPE  = 3'd2;
    localparam logic [2:0] ALU_OP_ITYPE  = 3'd3;
    localparam logic [2:0] ALU_OP_LUI    = 3'd4;
    localparam logic [2:0] ALU_OP_AUIPC  = 3'd5;

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

    always_comb begin
        alu_control = ALU_ADD;

        case (alu_op)
            ALU_OP_ADD: begin
                alu_control = ALU_ADD;
            end
            ALU_OP_BRANCH: begin
                case (funct3)
                    3'b000,
                    3'b001:  alu_control = ALU_SUB;   // beq, bne
                    3'b100,
                    3'b101:  alu_control = ALU_SLT;   // blt, bge
                    3'b110,
                    3'b111:  alu_control = ALU_SLTU;  // bltu, bgeu
                    default: alu_control = ALU_SUB;
                endcase
            end
            ALU_OP_RTYPE: begin
                case (funct3)
                    3'b000:  alu_control = (funct7[5]) ? ALU_SUB : ALU_ADD;
                    3'b001:  alu_control = ALU_SLL;
                    3'b010:  alu_control = ALU_SLT;
                    3'b011:  alu_control = ALU_SLTU;
                    3'b100:  alu_control = ALU_XOR;
                    3'b101:  alu_control = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110:  alu_control = ALU_OR;
                    3'b111:  alu_control = ALU_AND;
                    default: alu_control = ALU_ADD;
                endcase
            end
            ALU_OP_ITYPE: begin
                case (funct3)
                    3'b000:  alu_control = ALU_ADD;   // addi
                    3'b001:  alu_control = ALU_SLL;   // slli
                    3'b010:  alu_control = ALU_SLT;   // slti
                    3'b011:  alu_control = ALU_SLTU;  // sltiu
                    3'b100:  alu_control = ALU_XOR;   // xori
                    3'b101:  alu_control = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    3'b110:  alu_control = ALU_OR;    // ori
                    3'b111:  alu_control = ALU_AND;   // andi
                    default: alu_control = ALU_ADD;
                endcase
            end
            ALU_OP_LUI: begin
                alu_control = ALU_ADD;
            end
            ALU_OP_AUIPC: begin
                alu_control = ALU_ADD;
            end
            default: begin
                alu_control = ALU_ADD;
            end
        endcase
    end

endmodule
