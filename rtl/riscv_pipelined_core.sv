module riscv_pipelined_core (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] if_pc_debug,
    output logic [31:0] id_instruction_debug,
    output logic [31:0] ex_alu_result_debug,
    output logic [31:0] mem_alu_result_debug,
    output logic [31:0] wb_writeback_data_debug,
    output logic        stall_debug,
    output logic        flush_debug,
    output logic [1:0]  forward_a_debug,
    output logic [1:0]  forward_b_debug
);

    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;

    logic [31:0] if_pc;
    logic [31:0] if_next_pc;
    logic [31:0] if_pc_plus4;
    logic [31:0] if_instruction;
    logic        pc_write;
    logic        if_id_write;
    logic        control_stall;
    logic        if_id_flush;
    logic        id_ex_flush;

    logic [31:0] id_pc;
    logic [31:0] id_pc_plus4;
    logic [31:0] id_instruction;
    logic [6:0]  id_opcode;
    logic [4:0]  id_rd;
    logic [2:0]  id_funct3;
    logic [4:0]  id_rs1;
    logic [4:0]  id_rs2;
    logic [6:0]  id_funct7;
    logic        id_reg_write;
    logic        id_alu_src;
    logic        id_mem_read;
    logic        id_mem_write;
    logic        id_mem_to_reg;
    logic        id_branch;
    logic        id_jump;
    logic        id_jalr;
    logic [2:0]  id_alu_op;
    logic [2:0]  id_imm_src;
    logic [31:0] id_immediate;
    logic [31:0] id_read_data1;
    logic [31:0] id_read_data2;

    logic [31:0] ex_pc;
    logic [31:0] ex_pc_plus4;
    logic [31:0] ex_read_data1;
    logic [31:0] ex_read_data2;
    logic [31:0] ex_immediate;
    logic [4:0]  ex_rs1;
    logic [4:0]  ex_rs2;
    logic [4:0]  ex_rd;
    logic [2:0]  ex_funct3;
    logic [6:0]  ex_funct7;
    logic [6:0]  ex_opcode;
    logic        ex_reg_write;
    logic        ex_alu_src;
    logic        ex_mem_read;
    logic        ex_mem_write;
    logic        ex_mem_to_reg;
    logic        ex_branch;
    logic        ex_jump;
    logic        ex_jalr;
    logic [2:0]  ex_alu_op;
    logic [3:0]  ex_alu_control_signal;
    logic [1:0]  ex_forward_a;
    logic [1:0]  ex_forward_b;
    logic [31:0] ex_forwarded_data1;
    logic [31:0] ex_forwarded_data2;
    logic [31:0] ex_alu_operand_a;
    logic [31:0] ex_alu_operand_b;
    logic [31:0] ex_alu_result;
    logic        ex_alu_zero;
    logic [31:0] ex_branch_target;
    logic        ex_branch_taken;

    logic [31:0] mem_pc_plus4;
    logic [31:0] mem_alu_result;
    logic [31:0] mem_write_data;
    logic [4:0]  mem_rd;
    logic [31:0] mem_branch_target;
    logic        mem_branch_taken;
    logic [31:0] mem_immediate;
    logic [6:0]  mem_opcode;
    logic        mem_reg_write;
    logic        mem_mem_read;
    logic        mem_mem_write;
    logic        mem_mem_to_reg;
    logic        mem_jump;
    logic [31:0] mem_memory_read_data;
    logic [31:0] mem_forward_data;

    logic [31:0] wb_pc_plus4;
    logic [31:0] wb_alu_result;
    logic [31:0] wb_memory_read_data;
    logic [31:0] wb_immediate;
    logic [4:0]  wb_rd;
    logic [6:0]  wb_opcode;
    logic        wb_reg_write;
    logic        wb_mem_to_reg;
    logic        wb_jump;
    logic [31:0] wb_writeback_data;

    // ---------------------------------------------------------------------
    // IF stage: fetch the instruction at the current PC.
    // ---------------------------------------------------------------------
    program_counter u_program_counter (
        .clk(clk),
        .reset(reset),
        .next_pc(if_next_pc),
        .pc(if_pc)
    );

    instruction_memory u_instruction_memory (
        .address(if_pc),
        .instruction(if_instruction)
    );

    assign if_pc_plus4 = if_pc + 32'd4;

    // Phase 7 resolves branch and jump targets in EX, but it does not flush
    // younger instructions yet. Branch-heavy programs are Phase 8/9 work.
    always_comb begin
        if_next_pc = if_pc_plus4;

        if (!pc_write) begin
            if_next_pc = if_pc;
        end else if (ex_branch_taken || ex_jump) begin
            if_next_pc = ex_branch_target;
        end
    end

    hazard_detection_unit u_hazard_detection_unit (
        .if_id_rs1(id_rs1),
        .if_id_rs2(id_rs2),
        .id_ex_rd(ex_rd),
        .id_ex_mem_read(ex_mem_read),
        .branch_taken(ex_branch_taken),
        .jump_taken(ex_jump),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_stall(control_stall),
        .if_id_flush(if_id_flush),
        .id_ex_flush(id_ex_flush)
    );

    // ---------------------------------------------------------------------
    // IF/ID pipeline register.
    // ---------------------------------------------------------------------
    if_id_reg u_if_id_reg (
        .clk(clk),
        .reset(reset),
        .write_enable(if_id_write),
        .flush(if_id_flush),
        .pc_in(if_pc),
        .pc_plus4_in(if_pc_plus4),
        .instruction_in(if_instruction),
        .pc_out(id_pc),
        .pc_plus4_out(id_pc_plus4),
        .instruction_out(id_instruction)
    );

    // ---------------------------------------------------------------------
    // ID stage: decode instruction fields, control, immediates, and operands.
    // ---------------------------------------------------------------------
    assign id_opcode = id_instruction[6:0];
    assign id_rd     = id_instruction[11:7];
    assign id_funct3 = id_instruction[14:12];
    assign id_rs1    = id_instruction[19:15];
    assign id_rs2    = id_instruction[24:20];
    assign id_funct7 = id_instruction[31:25];

    control_unit u_control_unit (
        .opcode(id_opcode),
        .reg_write(id_reg_write),
        .alu_src(id_alu_src),
        .mem_read(id_mem_read),
        .mem_write(id_mem_write),
        .mem_to_reg(id_mem_to_reg),
        .branch(id_branch),
        .jump(id_jump),
        .jalr(id_jalr),
        .alu_op(id_alu_op),
        .imm_src(id_imm_src)
    );

    immediate_generator u_immediate_generator (
        .instruction(id_instruction),
        .imm_src(id_imm_src),
        .imm_out(id_immediate)
    );

    register_file u_register_file (
        .clk(clk),
        .reset(reset),
        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(wb_rd),
        .write_data(wb_writeback_data),
        .reg_write(wb_reg_write),
        .read_data1(id_read_data1),
        .read_data2(id_read_data2)
    );

    // ---------------------------------------------------------------------
    // ID/EX pipeline register.
    // ---------------------------------------------------------------------
    id_ex_reg u_id_ex_reg (
        .clk(clk),
        .reset(reset),
        .flush(id_ex_flush),
        .pc_in(id_pc),
        .pc_plus4_in(id_pc_plus4),
        .read_data1_in(id_read_data1),
        .read_data2_in(id_read_data2),
        .immediate_in(id_immediate),
        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .rd_in(id_rd),
        .funct3_in(id_funct3),
        .funct7_in(id_funct7),
        .opcode_in(id_opcode),
        .reg_write_in(id_reg_write),
        .alu_src_in(id_alu_src),
        .mem_read_in(id_mem_read),
        .mem_write_in(id_mem_write),
        .mem_to_reg_in(id_mem_to_reg),
        .branch_in(id_branch),
        .jump_in(id_jump),
        .jalr_in(id_jalr),
        .alu_op_in(id_alu_op),
        .pc_out(ex_pc),
        .pc_plus4_out(ex_pc_plus4),
        .read_data1_out(ex_read_data1),
        .read_data2_out(ex_read_data2),
        .immediate_out(ex_immediate),
        .rs1_out(ex_rs1),
        .rs2_out(ex_rs2),
        .rd_out(ex_rd),
        .funct3_out(ex_funct3),
        .funct7_out(ex_funct7),
        .opcode_out(ex_opcode),
        .reg_write_out(ex_reg_write),
        .alu_src_out(ex_alu_src),
        .mem_read_out(ex_mem_read),
        .mem_write_out(ex_mem_write),
        .mem_to_reg_out(ex_mem_to_reg),
        .branch_out(ex_branch),
        .jump_out(ex_jump),
        .jalr_out(ex_jalr),
        .alu_op_out(ex_alu_op)
    );

    // ---------------------------------------------------------------------
    // EX stage: select ALU operands, execute, and calculate branch targets.
    // ---------------------------------------------------------------------
    alu_control u_alu_control (
        .alu_op(ex_alu_op),
        .funct3(ex_funct3),
        .funct7(ex_funct7),
        .alu_control(ex_alu_control_signal)
    );

    forwarding_unit u_forwarding_unit (
        .id_ex_rs1(ex_rs1),
        .id_ex_rs2(ex_rs2),
        .ex_mem_rd(mem_rd),
        .mem_wb_rd(wb_rd),
        .ex_mem_reg_write(mem_reg_write),
        .mem_wb_reg_write(wb_reg_write),
        .forward_a(ex_forward_a),
        .forward_b(ex_forward_b)
    );

    always_comb begin
        mem_forward_data = mem_alu_result;

        if (mem_jump) begin
            mem_forward_data = mem_pc_plus4;
        end else if (mem_opcode == OPCODE_LUI) begin
            mem_forward_data = mem_immediate;
        end
    end

    always_comb begin
        ex_forwarded_data1 = ex_read_data1;

        case (ex_forward_a)
            2'b10:   ex_forwarded_data1 = mem_forward_data;
            2'b01:   ex_forwarded_data1 = wb_writeback_data;
            default: ex_forwarded_data1 = ex_read_data1;
        endcase
    end

    always_comb begin
        ex_forwarded_data2 = ex_read_data2;

        case (ex_forward_b)
            2'b10:   ex_forwarded_data2 = mem_forward_data;
            2'b01:   ex_forwarded_data2 = wb_writeback_data;
            default: ex_forwarded_data2 = ex_read_data2;
        endcase
    end

    assign ex_alu_operand_a = (ex_opcode == OPCODE_AUIPC) ? ex_pc : ex_forwarded_data1;
    assign ex_alu_operand_b = ex_alu_src ? ex_immediate : ex_forwarded_data2;

    alu u_alu (
        .operand_a(ex_alu_operand_a),
        .operand_b(ex_alu_operand_b),
        .alu_control(ex_alu_control_signal),
        .result(ex_alu_result),
        .zero(ex_alu_zero)
    );

    always_comb begin
        ex_branch_target = ex_pc + ex_immediate;

        if (ex_jump && ex_jalr) begin
            ex_branch_target = (ex_forwarded_data1 + ex_immediate) & 32'hffff_fffe;
        end
    end

    always_comb begin
        ex_branch_taken = 1'b0;

        if (ex_branch) begin
            case (ex_funct3)
                3'b000:  ex_branch_taken = (ex_forwarded_data1 == ex_forwarded_data2);
                3'b001:  ex_branch_taken = (ex_forwarded_data1 != ex_forwarded_data2);
                3'b100:  ex_branch_taken = ($signed(ex_forwarded_data1) < $signed(ex_forwarded_data2));
                3'b101:  ex_branch_taken = ($signed(ex_forwarded_data1) >= $signed(ex_forwarded_data2));
                default: ex_branch_taken = 1'b0;
            endcase
        end
    end

    // ---------------------------------------------------------------------
    // EX/MEM pipeline register.
    // ---------------------------------------------------------------------
    ex_mem_reg u_ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .pc_plus4_in(ex_pc_plus4),
        .alu_result_in(ex_alu_result),
        .write_data_in(ex_forwarded_data2),
        .rd_in(ex_rd),
        .branch_target_in(ex_branch_target),
        .branch_taken_in(ex_branch_taken),
        .immediate_in(ex_immediate),
        .opcode_in(ex_opcode),
        .reg_write_in(ex_reg_write),
        .mem_read_in(ex_mem_read),
        .mem_write_in(ex_mem_write),
        .mem_to_reg_in(ex_mem_to_reg),
        .jump_in(ex_jump),
        .pc_plus4_out(mem_pc_plus4),
        .alu_result_out(mem_alu_result),
        .write_data_out(mem_write_data),
        .rd_out(mem_rd),
        .branch_target_out(mem_branch_target),
        .branch_taken_out(mem_branch_taken),
        .immediate_out(mem_immediate),
        .opcode_out(mem_opcode),
        .reg_write_out(mem_reg_write),
        .mem_read_out(mem_mem_read),
        .mem_write_out(mem_mem_write),
        .mem_to_reg_out(mem_mem_to_reg),
        .jump_out(mem_jump)
    );

    // ---------------------------------------------------------------------
    // MEM stage: access data memory.
    // ---------------------------------------------------------------------
    data_memory u_data_memory (
        .clk(clk),
        .mem_read(mem_mem_read),
        .mem_write(mem_mem_write),
        .address(mem_alu_result),
        .write_data(mem_write_data),
        .read_data(mem_memory_read_data)
    );

    // ---------------------------------------------------------------------
    // MEM/WB pipeline register.
    // ---------------------------------------------------------------------
    mem_wb_reg u_mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .pc_plus4_in(mem_pc_plus4),
        .alu_result_in(mem_alu_result),
        .memory_read_data_in(mem_memory_read_data),
        .immediate_in(mem_immediate),
        .rd_in(mem_rd),
        .opcode_in(mem_opcode),
        .reg_write_in(mem_reg_write),
        .mem_to_reg_in(mem_mem_to_reg),
        .jump_in(mem_jump),
        .pc_plus4_out(wb_pc_plus4),
        .alu_result_out(wb_alu_result),
        .memory_read_data_out(wb_memory_read_data),
        .immediate_out(wb_immediate),
        .rd_out(wb_rd),
        .opcode_out(wb_opcode),
        .reg_write_out(wb_reg_write),
        .mem_to_reg_out(wb_mem_to_reg),
        .jump_out(wb_jump)
    );

    // ---------------------------------------------------------------------
    // WB stage: choose the final value written to rd.
    // ---------------------------------------------------------------------
    always_comb begin
        wb_writeback_data = wb_alu_result;

        if (wb_mem_to_reg) begin
            wb_writeback_data = wb_memory_read_data;
        end else if (wb_jump) begin
            wb_writeback_data = wb_pc_plus4;
        end else if (wb_opcode == OPCODE_LUI) begin
            wb_writeback_data = wb_immediate;
        end
    end

    assign if_pc_debug             = if_pc;
    assign id_instruction_debug    = id_instruction;
    assign ex_alu_result_debug     = ex_alu_result;
    assign mem_alu_result_debug    = mem_alu_result;
    assign wb_writeback_data_debug = wb_writeback_data;
    assign stall_debug             = control_stall;
    assign flush_debug             = if_id_flush || id_ex_flush;
    assign forward_a_debug         = ex_forward_a;
    assign forward_b_debug         = ex_forward_b;

endmodule
