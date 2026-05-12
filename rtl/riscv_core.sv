module riscv_core (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] pc_debug,
    output logic [31:0] instruction_debug,
    output logic [31:0] alu_result_debug,
    output logic [31:0] writeback_data_debug
);

    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;

    logic [31:0] pc;
    logic [31:0] next_pc;
    logic [31:0] pc_plus_4;
    logic [31:0] instruction;

    logic [6:0] opcode;
    logic [4:0] rd;
    logic [2:0] funct3;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic       funct7_bit5;

    logic        reg_write;
    logic        alu_src;
    logic        mem_read;
    logic        mem_write;
    logic        mem_to_reg;
    logic        branch;
    logic        jump;
    logic        jalr;
    logic [2:0]  alu_op;
    logic [2:0]  imm_src;
    logic [3:0]  alu_control_signal;

    logic [31:0] imm_out;
    logic [31:0] read_data1;
    logic [31:0] read_data2;
    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic        alu_zero;
    logic [31:0] data_memory_read_data;
    logic [31:0] writeback_data;

    logic        branch_taken;
    logic [31:0] branch_target;
    logic [31:0] jal_target;
    logic [31:0] jalr_target;

    program_counter u_program_counter (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    instruction_memory u_instruction_memory (
        .address(pc),
        .instruction(instruction)
    );

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7_bit5 = instruction[30];

    control_unit u_control_unit (
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

    immediate_generator u_immediate_generator (
        .instruction(instruction[31:7]),
        .imm_src(imm_src),
        .imm_out(imm_out)
    );

    register_file u_register_file (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(writeback_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    alu_control u_alu_control (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_bit5(funct7_bit5),
        .alu_control(alu_control_signal)
    );

    // AUIPC uses the current PC as ALU operand A. All other supported
    // instructions use rs1 as operand A.
    assign alu_operand_a = (opcode == OPCODE_AUIPC) ? pc : read_data1;
    assign alu_operand_b = alu_src ? imm_out : read_data2;

    alu u_alu (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control_signal),
        .result(alu_result),
        .zero(alu_zero)
    );

    data_memory u_data_memory (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(data_memory_read_data)
    );

    assign pc_plus_4     = pc + 32'd4;
    assign branch_target = pc + imm_out;
    assign jal_target    = pc + imm_out;
    assign jalr_target   = (read_data1 + imm_out) & 32'hffff_fffe;

    always_comb begin
        branch_taken = 1'b0;

        if (branch) begin
            case (funct3)
                3'b000:  branch_taken = alu_zero;                              // beq
                3'b001:  branch_taken = !alu_zero;                             // bne
                3'b100:  branch_taken = ($signed(read_data1) < $signed(read_data2));  // blt
                3'b101:  branch_taken = ($signed(read_data1) >= $signed(read_data2)); // bge
                default: branch_taken = 1'b0;
            endcase
        end
    end

    always_comb begin
        next_pc = pc_plus_4;

        if (branch_taken) begin
            next_pc = branch_target;
        end else if (jump && jalr) begin
            next_pc = jalr_target;
        end else if (jump && (opcode == OPCODE_JAL)) begin
            next_pc = jal_target;
        end
    end

    always_comb begin
        writeback_data = alu_result;

        if (mem_to_reg) begin
            writeback_data = data_memory_read_data;
        end else if (jump) begin
            writeback_data = pc_plus_4;
        end else if (opcode == OPCODE_LUI) begin
            writeback_data = imm_out;
        end
    end

    assign pc_debug             = pc;
    assign instruction_debug    = instruction;
    assign alu_result_debug     = alu_result;
    assign writeback_data_debug = writeback_data;

endmodule
