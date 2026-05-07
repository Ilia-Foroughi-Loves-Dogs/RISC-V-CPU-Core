module ex_mem_reg (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_plus4_in,
    input  logic [31:0] alu_result_in,
    input  logic [31:0] write_data_in,
    input  logic [4:0]  rd_in,
    input  logic [31:0] branch_target_in,
    input  logic        branch_taken_in,
    input  logic [31:0] immediate_in,
    input  logic [6:0]  opcode_in,
    input  logic        reg_write_in,
    input  logic        mem_read_in,
    input  logic        mem_write_in,
    input  logic        mem_to_reg_in,
    input  logic        jump_in,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0]  rd_out,
    output logic [31:0] branch_target_out,
    output logic        branch_taken_out,
    output logic [31:0] immediate_out,
    output logic [6:0]  opcode_out,
    output logic        reg_write_out,
    output logic        mem_read_out,
    output logic        mem_write_out,
    output logic        mem_to_reg_out,
    output logic        jump_out
);

    localparam logic [6:0] OPCODE_NOP = 7'b0010011;

    // EX/MEM stores the ALU result, store data, branch decision, destination
    // register, and the control signals needed by memory and writeback.
    always_ff @(posedge clk) begin
        if (reset) begin
            pc_plus4_out      <= 32'h0000_0000;
            alu_result_out    <= 32'h0000_0000;
            write_data_out    <= 32'h0000_0000;
            rd_out            <= 5'd0;
            branch_target_out <= 32'h0000_0000;
            branch_taken_out  <= 1'b0;
            immediate_out     <= 32'h0000_0000;
            opcode_out        <= OPCODE_NOP;
            reg_write_out     <= 1'b0;
            mem_read_out      <= 1'b0;
            mem_write_out     <= 1'b0;
            mem_to_reg_out    <= 1'b0;
            jump_out          <= 1'b0;
        end else begin
            pc_plus4_out      <= pc_plus4_in;
            alu_result_out    <= alu_result_in;
            write_data_out    <= write_data_in;
            rd_out            <= rd_in;
            branch_target_out <= branch_target_in;
            branch_taken_out  <= branch_taken_in;
            immediate_out     <= immediate_in;
            opcode_out        <= opcode_in;
            reg_write_out     <= reg_write_in;
            mem_read_out      <= mem_read_in;
            mem_write_out     <= mem_write_in;
            mem_to_reg_out    <= mem_to_reg_in;
            jump_out          <= jump_in;
        end
    end

endmodule
