module register_file (
    input  logic        clk,
    input  logic        reset,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    input  logic        reg_write,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] registers [0:31];

    integer i;

    // Writes are synchronous. Register x0 ignores writes and always stays zero.
    always_ff @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0000_0000;
            end
        end else if (reg_write && (rd != 5'd0)) begin
            registers[rd] <= write_data;
        end
    end

    // Reads are asynchronous so source operands are available immediately.
    assign read_data1 = (rs1 == 5'd0) ? 32'h0000_0000 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'h0000_0000 : registers[rs2];

endmodule
