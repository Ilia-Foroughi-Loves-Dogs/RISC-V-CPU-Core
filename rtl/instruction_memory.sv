module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    localparam int MEM_WORDS = 1024;

    logic [31:0] memory [0:MEM_WORDS-1];

    initial begin
        $readmemh("tests/programs/program.mem", memory);
    end

    // Instructions are word-aligned, so bits [1:0] are ignored.
    assign instruction = memory[address[31:2]];

endmodule
