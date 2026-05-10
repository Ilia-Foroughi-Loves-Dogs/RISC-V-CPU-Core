`timescale 1ns/1ps

module tb_hazard_detection_unit;

    logic [4:0] if_id_rs1;
    logic [4:0] if_id_rs2;
    logic [4:0] id_ex_rd;
    logic       id_ex_mem_read;
    logic       branch_taken;
    logic       jump_taken;
    logic       pc_write;
    logic       if_id_write;
    logic       control_stall;
    logic       if_id_flush;
    logic       id_ex_flush;
    int unsigned error_count;

    hazard_detection_unit dut (
        .if_id_rs1(if_id_rs1),
        .if_id_rs2(if_id_rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .branch_taken(branch_taken),
        .jump_taken(jump_taken),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_stall(control_stall),
        .if_id_flush(if_id_flush),
        .id_ex_flush(id_ex_flush)
    );

    task automatic check_outputs(
        input string name,
        input logic expected_pc_write,
        input logic expected_if_id_write,
        input logic expected_control_stall,
        input logic expected_if_id_flush,
        input logic expected_id_ex_flush
    );
        #1;
        if ((pc_write !== expected_pc_write) ||
            (if_id_write !== expected_if_id_write) ||
            (control_stall !== expected_control_stall) ||
            (if_id_flush !== expected_if_id_flush) ||
            (id_ex_flush !== expected_id_ex_flush)) begin
            error_count++;
            $error("%s expected pc=%b ifid_we=%b stall=%b ifid_flush=%b idex_flush=%b, got pc=%b ifid_we=%b stall=%b ifid_flush=%b idex_flush=%b",
                   name, expected_pc_write, expected_if_id_write,
                   expected_control_stall, expected_if_id_flush,
                   expected_id_ex_flush, pc_write, if_id_write,
                   control_stall, if_id_flush, id_ex_flush);
        end
    endtask

    initial begin
        error_count = 0;

        if_id_rs1 = 5'd1;
        if_id_rs2 = 5'd2;
        id_ex_rd = 5'd3;
        id_ex_mem_read = 1'b0;
        branch_taken = 1'b0;
        jump_taken = 1'b0;
        check_outputs("no hazard", 1'b1, 1'b1, 1'b0, 1'b0, 1'b0);

        id_ex_rd = 5'd1;
        id_ex_mem_read = 1'b1;
        check_outputs("load-use on rs1", 1'b0, 1'b0, 1'b1, 1'b0, 1'b1);

        id_ex_rd = 5'd2;
        check_outputs("load-use on rs2", 1'b0, 1'b0, 1'b1, 1'b0, 1'b1);

        id_ex_rd = 5'd0;
        check_outputs("load to x0 ignored", 1'b1, 1'b1, 1'b0, 1'b0, 1'b0);

        id_ex_rd = 5'd3;
        id_ex_mem_read = 1'b0;
        branch_taken = 1'b1;
        check_outputs("taken branch flush", 1'b1, 1'b1, 1'b0, 1'b1, 1'b1);

        branch_taken = 1'b0;
        jump_taken = 1'b1;
        check_outputs("taken jump flush", 1'b1, 1'b1, 1'b0, 1'b1, 1'b1);

        if (error_count == 0) begin
            $display("PASS: hazard_detection_unit tests completed");
            $finish;
        end else begin
            $fatal(1, "FAIL: hazard_detection_unit had %0d error(s)", error_count);
        end
    end

endmodule
