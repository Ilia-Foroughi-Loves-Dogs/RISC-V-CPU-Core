module data_memory (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    localparam int MEM_WORDS = 1024;

    logic [31:0] memory [0:MEM_WORDS-1];

    integer i;

    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
            memory[i] = 32'h0000_0000;
        end
    end

    // Word writes happen on the rising clock edge.
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[address[31:2]] <= write_data;
        end
    end

    // Reads are combinational and return zero when reading is disabled.
    assign read_data = mem_read ? memory[address[31:2]] : 32'h0000_0000;

endmodule
