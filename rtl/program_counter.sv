module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] next_pc,
    output logic [31:0] pc
);

    // The PC updates on each clock edge and returns to address 0 on reset.
    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= 32'h0000_0000;
        end else begin
            pc <= next_pc;
        end
    end

endmodule
