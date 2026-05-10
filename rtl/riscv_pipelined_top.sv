module riscv_pipelined_top (
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

    riscv_pipelined_core u_riscv_pipelined_core (
        .clk(clk),
        .reset(reset),
        .if_pc_debug(if_pc_debug),
        .id_instruction_debug(id_instruction_debug),
        .ex_alu_result_debug(ex_alu_result_debug),
        .mem_alu_result_debug(mem_alu_result_debug),
        .wb_writeback_data_debug(wb_writeback_data_debug),
        .stall_debug(stall_debug),
        .flush_debug(flush_debug),
        .forward_a_debug(forward_a_debug),
        .forward_b_debug(forward_b_debug)
    );

endmodule
