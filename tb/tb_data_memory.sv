`timescale 1ns/1ps

module tb_data_memory;

    logic        clk;
    logic        mem_read;
    logic        mem_write;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    data_memory dut (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Starting data_memory test");

        mem_read = 1'b1;
        mem_write = 1'b0;
        address = 32'h0000_0000;
        write_data = 32'h0000_0000;
        #1;
        if (read_data !== 32'h0000_0000) $error("Memory did not initialize to zero");

        mem_read = 1'b0;
        mem_write = 1'b1;
        address = 32'h0000_0008;
        write_data = 32'hcafe_babe;
        @(posedge clk);
        #1;

        mem_write = 1'b0;
        mem_read = 1'b1;
        #1;
        if (read_data !== 32'hcafe_babe) $error("Memory readback failed: %h", read_data);

        mem_read = 1'b0;
        #1;
        if (read_data !== 32'h0000_0000) $error("Read data should be zero when mem_read is low");

        $display("data_memory test complete");
        $finish;
    end

endmodule
