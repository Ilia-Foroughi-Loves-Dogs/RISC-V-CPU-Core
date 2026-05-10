module hazard_detection_unit (
    input  logic [4:0] if_id_rs1,
    input  logic [4:0] if_id_rs2,
    input  logic [4:0] id_ex_rd,
    input  logic       id_ex_mem_read,
    input  logic       branch_taken,
    input  logic       jump_taken,
    output logic       pc_write,
    output logic       if_id_write,
    output logic       control_stall,
    output logic       if_id_flush,
    output logic       id_ex_flush
);

    logic load_use_hazard;
    logic control_hazard;

    assign load_use_hazard = id_ex_mem_read &&
                             (id_ex_rd != 5'd0) &&
                             ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2));
    assign control_hazard  = branch_taken || jump_taken;

    always_comb begin
        pc_write      = 1'b1;
        if_id_write   = 1'b1;
        control_stall = 1'b0;
        if_id_flush   = 1'b0;
        id_ex_flush   = 1'b0;

        if (load_use_hazard) begin
            // Hold IF and ID while converting the current ID/EX contents into
            // a bubble. The load advances, then the dependent instruction can
            // use MEM/WB forwarding on the following cycle.
            pc_write      = 1'b0;
            if_id_write   = 1'b0;
            control_stall = 1'b1;
            id_ex_flush   = 1'b1;
        end

        if (control_hazard) begin
            // Branches and jumps resolve in EX. Flush the younger wrong-path
            // instructions that are sitting in IF/ID and ID/EX.
            if_id_flush = 1'b1;
            id_ex_flush = 1'b1;
        end
    end

endmodule
