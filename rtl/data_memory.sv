module data_memory (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    localparam int MEM_WORDS = 1024;
    localparam int ADDR_WIDTH = $clog2(MEM_WORDS);

    logic [31:0] memory [0:MEM_WORDS-1];
    logic [ADDR_WIDTH-1:0] word_index;
    logic unused_address_bits;

    integer i;

    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
            memory[i] = 32'h0000_0000;
        end
    end

    assign word_index = address[ADDR_WIDTH+1:2];
    assign unused_address_bits = &{1'b0, address[31:ADDR_WIDTH+2], address[1:0]};

    // Word writes happen on the rising clock edge.
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[word_index] <= write_data;
        end
    end

    // Reads are combinational and return zero when reading is disabled.
    assign read_data = mem_read ? memory[word_index] : 32'h0000_0000;

endmodule
