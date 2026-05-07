module mem_wb_reg (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_plus4_in,
    input  logic [31:0] alu_result_in,
    input  logic [31:0] memory_read_data_in,
    input  logic [31:0] immediate_in,
    input  logic [4:0]  rd_in,
    input  logic [6:0]  opcode_in,
    input  logic        reg_write_in,
    input  logic        mem_to_reg_in,
    input  logic        jump_in,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] memory_read_data_out,
    output logic [31:0] immediate_out,
    output logic [4:0]  rd_out,
    output logic [6:0]  opcode_out,
    output logic        reg_write_out,
    output logic        mem_to_reg_out,
    output logic        jump_out
);

    localparam logic [6:0] OPCODE_NOP = 7'b0010011;

    // MEM/WB stores final candidate result values and writeback control.
    always_ff @(posedge clk) begin
        if (reset) begin
            pc_plus4_out          <= 32'h0000_0000;
            alu_result_out        <= 32'h0000_0000;
            memory_read_data_out  <= 32'h0000_0000;
            immediate_out         <= 32'h0000_0000;
            rd_out                <= 5'd0;
            opcode_out            <= OPCODE_NOP;
            reg_write_out         <= 1'b0;
            mem_to_reg_out        <= 1'b0;
            jump_out              <= 1'b0;
        end else begin
            pc_plus4_out          <= pc_plus4_in;
            alu_result_out        <= alu_result_in;
            memory_read_data_out  <= memory_read_data_in;
            immediate_out         <= immediate_in;
            rd_out                <= rd_in;
            opcode_out            <= opcode_in;
            reg_write_out         <= reg_write_in;
            mem_to_reg_out        <= mem_to_reg_in;
            jump_out              <= jump_in;
        end
    end

endmodule
