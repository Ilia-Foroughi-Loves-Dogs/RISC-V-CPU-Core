`timescale 1ns/1ps

module tb_forwarding_unit;

    logic [4:0] id_ex_rs1;
    logic [4:0] id_ex_rs2;
    logic [4:0] ex_mem_rd;
    logic [4:0] mem_wb_rd;
    logic       ex_mem_reg_write;
    logic       mem_wb_reg_write;
    logic [1:0] forward_a;
    logic [1:0] forward_b;
    int unsigned error_count;

    forwarding_unit dut (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    task automatic check_forward(
        input string name,
        input logic [1:0] expected_a,
        input logic [1:0] expected_b
    );
        #1;
        if ((forward_a !== expected_a) || (forward_b !== expected_b)) begin
            error_count++;
            $error("%s expected A=%b B=%b, got A=%b B=%b",
                   name, expected_a, expected_b, forward_a, forward_b);
        end
    endtask

    initial begin
        error_count = 0;

        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;
        ex_mem_rd = 5'd0;
        mem_wb_rd = 5'd0;
        ex_mem_reg_write = 1'b0;
        mem_wb_reg_write = 1'b0;
        check_forward("no forwarding", 2'b00, 2'b00);

        ex_mem_rd = 5'd1;
        ex_mem_reg_write = 1'b1;
        check_forward("EX/MEM forwards rs1", 2'b10, 2'b00);

        ex_mem_rd = 5'd2;
        check_forward("EX/MEM forwards rs2", 2'b00, 2'b10);

        ex_mem_reg_write = 1'b0;
        mem_wb_rd = 5'd1;
        mem_wb_reg_write = 1'b1;
        check_forward("MEM/WB forwards rs1", 2'b01, 2'b00);

        mem_wb_rd = 5'd2;
        check_forward("MEM/WB forwards rs2", 2'b00, 2'b01);

        ex_mem_rd = 5'd1;
        mem_wb_rd = 5'd1;
        ex_mem_reg_write = 1'b1;
        mem_wb_reg_write = 1'b1;
        check_forward("EX/MEM has priority over MEM/WB", 2'b10, 2'b00);

        id_ex_rs1 = 5'd0;
        id_ex_rs2 = 5'd0;
        ex_mem_rd = 5'd0;
        mem_wb_rd = 5'd0;
        check_forward("x0 is never forwarded", 2'b00, 2'b00);

        if (error_count == 0) begin
            $display("PASS: forwarding_unit tests completed");
            $finish;
        end else begin
            $fatal(1, "FAIL: forwarding_unit had %0d error(s)", error_count);
        end
    end

endmodule
