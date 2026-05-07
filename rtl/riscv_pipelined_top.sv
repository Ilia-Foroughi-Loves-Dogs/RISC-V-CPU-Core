module riscv_pipelined_top (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] if_pc_debug,
    output logic [31:0] id_instruction_debug,
    output logic [31:0] ex_alu_result_debug,
    output logic [31:0] mem_alu_result_debug,
    output logic [31:0] wb_writeback_data_debug
);

    riscv_pipelined_core u_riscv_pipelined_core (
        .clk(clk),
        .reset(reset),
        .if_pc_debug(if_pc_debug),
        .id_instruction_debug(id_instruction_debug),
        .ex_alu_result_debug(ex_alu_result_debug),
        .mem_alu_result_debug(mem_alu_result_debug),
        .wb_writeback_data_debug(wb_writeback_data_debug)
    );

endmodule
