`timescale 1ns/1ps

module tb_register_file;

    logic        clk;
    logic        reset;
    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;
    logic [31:0] write_data;
    logic        reg_write;
    logic [31:0] read_data1;
    logic [31:0] read_data2;

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
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Starting register_file test");

        reset = 1'b1;
        reg_write = 1'b0;
        rs1 = 5'd1;
        rs2 = 5'd2;
        rd = 5'd0;
        write_data = 32'h0000_0000;
        @(posedge clk);
        #1;
        if (read_data1 !== 32'h0000_0000) $error("Reset did not clear x1");
        if (read_data2 !== 32'h0000_0000) $error("Reset did not clear x2");

        reset = 1'b0;
        rd = 5'd5;
        write_data = 32'h1234_5678;
        reg_write = 1'b1;
        @(posedge clk);
        #1;
        rs1 = 5'd5;
        #1;
        if (read_data1 !== 32'h1234_5678) $error("Read from x5 failed: %h", read_data1);

        rd = 5'd0;
        write_data = 32'hffff_ffff;
        @(posedge clk);
        #1;
        rs2 = 5'd0;
        #1;
        if (read_data2 !== 32'h0000_0000) $error("x0 did not stay zero: %h", read_data2);

        reg_write = 1'b0;
        rd = 5'd6;
        write_data = 32'hdead_beef;
        @(posedge clk);
        #1;
        rs1 = 5'd6;
        #1;
        if (read_data1 !== 32'h0000_0000) $error("Write occurred while reg_write was low");

        $display("register_file test complete");
        $finish;
    end

endmodule
