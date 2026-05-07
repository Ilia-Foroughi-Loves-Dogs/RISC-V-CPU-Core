module riscv_top (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] pc_debug,
    output logic [31:0] instruction_debug,
    output logic [31:0] alu_result_debug,
    output logic [31:0] writeback_data_debug
);

    riscv_core u_riscv_core (
        .clk(clk),
        .reset(reset),
        .pc_debug(pc_debug),
        .instruction_debug(instruction_debug),
        .alu_result_debug(alu_result_debug),
        .writeback_data_debug(writeback_data_debug)
    );

endmodule
