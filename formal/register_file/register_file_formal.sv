module register_file_formal;
    logic        clk;
    (* anyseq *) logic        reset;
    (* anyseq *) logic [4:0]  rs1;
    (* anyseq *) logic [4:0]  rs2;
    (* anyseq *) logic [4:0]  rd;
    (* anyseq *) logic [31:0] write_data;
    (* anyseq *) logic        reg_write;
    logic [31:0] read_data1;
    logic [31:0] read_data2;
    logic        past_valid;

    register_file dut (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        assume(reset);
        past_valid = 1'b0;
    end

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : reg_checks
            always_ff @(posedge clk) begin
                if (past_valid && $past(reset)) begin
                    assert(dut.registers[i] == 32'h0000_0000);
                end
            end
        end
    endgenerate

    always_comb begin
        assert(read_data1 == ((rs1 == 5'd0) ? 32'h0000_0000 : dut.registers[rs1]));
        assert(read_data2 == ((rs2 == 5'd0) ? 32'h0000_0000 : dut.registers[rs2]));

        if (rs1 == 5'd0) begin
            assert(read_data1 == 32'h0000_0000);
        end

        if (rs2 == 5'd0) begin
            assert(read_data2 == 32'h0000_0000);
        end

        if (rs1 == rs2) begin
            assert(read_data1 == read_data2);
        end
    end

    always_ff @(posedge clk) begin
        past_valid <= 1'b1;

        if (past_valid) begin
            assert(dut.registers[0] == 32'h0000_0000);
        end

        if (past_valid && $past(reg_write) && ($past(rd) == 5'd0)) begin
            assert(dut.registers[0] == 32'h0000_0000);
        end

        if (past_valid && !$past(reset) && $past(reg_write) && ($past(rd) != 5'd0)) begin
            assert(dut.registers[$past(rd)] == $past(write_data));
        end
    end
endmodule
