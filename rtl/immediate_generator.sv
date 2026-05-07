module immediate_generator (
    input  logic [31:0] instruction,
    input  logic [2:0]  imm_src,
    output logic [31:0] imm_out
);

    localparam logic [2:0] IMM_I = 3'd0;
    localparam logic [2:0] IMM_S = 3'd1;
    localparam logic [2:0] IMM_B = 3'd2;
    localparam logic [2:0] IMM_U = 3'd3;
    localparam logic [2:0] IMM_J = 3'd4;

    always_comb begin
        case (imm_src)
            IMM_I: begin
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end
            IMM_S: begin
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            IMM_B: begin
                imm_out = {{19{instruction[31]}}, instruction[31], instruction[7],
                           instruction[30:25], instruction[11:8], 1'b0};
            end
            IMM_U: begin
                imm_out = {instruction[31:12], 12'b0};
            end
            IMM_J: begin
                imm_out = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                           instruction[20], instruction[30:21], 1'b0};
            end
            default: begin
                imm_out = 32'h0000_0000;
            end
        endcase
    end

endmodule
