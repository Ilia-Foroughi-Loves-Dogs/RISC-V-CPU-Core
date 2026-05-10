module if_id_reg (
    input  logic        clk,
    input  logic        reset,
    input  logic        write_enable,
    input  logic        flush,
    input  logic [31:0] pc_in,
    input  logic [31:0] pc_plus4_in,
    input  logic [31:0] instruction_in,
    output logic [31:0] pc_out,
    output logic [31:0] pc_plus4_out,
    output logic [31:0] instruction_out
);

    localparam logic [31:0] NOP = 32'h0000_0013; // addi x0, x0, 0

    // IF/ID stores the fetched instruction and its fetch PC for decode.
    always_ff @(posedge clk) begin
        if (reset || flush) begin
            pc_out          <= 32'h0000_0000;
            pc_plus4_out    <= 32'h0000_0000;
            instruction_out <= NOP;
        end else if (write_enable) begin
            pc_out          <= pc_in;
            pc_plus4_out    <= pc_plus4_in;
            instruction_out <= instruction_in;
        end
    end

endmodule
