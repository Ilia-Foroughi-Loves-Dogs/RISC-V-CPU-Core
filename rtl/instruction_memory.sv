module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    localparam int MEM_WORDS = 1024;
    localparam logic [31:0] NOP = 32'h0000_0013; // addi x0, x0, 0

    logic [31:0] memory [0:MEM_WORDS-1];
    string program_path;
    integer i;
    integer program_file;
    integer scan_count;
    integer loaded_words;
    logic [31:0] instruction_word;

    initial begin
        program_path = "tests/programs/program.mem";

        if (!$value$plusargs("PROGRAM=%s", program_path)) begin
            program_path = "tests/programs/program.mem";
        end

        for (i = 0; i < MEM_WORDS; i = i + 1) begin
            memory[i] = NOP;
        end

        program_file = $fopen(program_path, "r");
        if (program_file == 0) begin
            $fatal(1, "Could not open instruction program: %s", program_path);
        end

        loaded_words = 0;
        while (!$feof(program_file) && (loaded_words < MEM_WORDS)) begin
            scan_count = $fscanf(program_file, "%h\n", instruction_word);
            if (scan_count == 1) begin
                memory[loaded_words] = instruction_word;
                loaded_words = loaded_words + 1;
            end
        end
        $fclose(program_file);

        $display("Instruction memory loaded %0d word(s) from: %s",
                 loaded_words, program_path);
    end

    // Instructions are word-aligned, so bits [1:0] are ignored.
    assign instruction = memory[address[31:2]];

endmodule
