`timescale 1ns/1ps

module tb_program_counter;

    logic        clk;
    logic        reset;
    logic [31:0] next_pc;
    logic [31:0] pc;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Starting program_counter test");

        reset = 1'b1;
        next_pc = 32'h0000_0100;
        @(posedge clk);
        #1;
        if (pc !== 32'h0000_0000) $error("PC reset failed: pc=%h", pc);

        reset = 1'b0;
        next_pc = 32'h0000_0004;
        @(posedge clk);
        #1;
        if (pc !== 32'h0000_0004) $error("PC update failed: pc=%h", pc);

        next_pc = 32'h0000_0020;
        @(posedge clk);
        #1;
        if (pc !== 32'h0000_0020) $error("Second PC update failed: pc=%h", pc);

        $display("program_counter test complete");
        $finish;
    end

endmodule
