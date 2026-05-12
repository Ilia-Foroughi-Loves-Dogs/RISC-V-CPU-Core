module program_counter_formal;
    logic        clk;
    (* anyseq *) logic        reset;
    (* anyseq *) logic [31:0] next_pc;
    logic [31:0] pc;
    logic        past_valid;

    program_counter dut (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    initial begin
        assume(reset);
        past_valid = 1'b0;
    end

    always_ff @(posedge clk) begin
        past_valid <= 1'b1;

        if (past_valid) begin
            if ($past(reset)) begin
                assert(pc == 32'h0000_0000);
            end else begin
                assert(pc == $past(next_pc));
            end

            if (!$isunknown($past(reset)) && !$isunknown($past(next_pc))) begin
                assert(!$isunknown(pc));
            end
        end
    end
endmodule
