import rv32_pipeline_pkg::*;

module Hazard_Unit (
    clk,
    rst_n,
    if_id_rs1,
    if_id_rs2,

    id_ex_rd,
    ex_mem_rd,
    mem_wb_rd,
    id_ex_regwrite,
    ex_mem_regwrite,
    mem_wb_regwrite,

    id_ex_mem_read_en,

    branch_taken,

    pc_stall,
    if_id_stall,
    id_ex_stall,

    if_id_bubble,
    id_ex_bubble,
    ex_mem_bubble,

    forward_rs1,
    forward_rs2
);
    input wire logic clk;
    input wire logic rst_n;
    input wire reg_addr_t if_id_rs1;
    input wire reg_addr_t if_id_rs2;

    input wire reg_addr_t id_ex_rd;
    input wire reg_addr_t ex_mem_rd;
    input wire reg_addr_t mem_wb_rd;
    input wire logic id_ex_regwrite;
    input wire logic ex_mem_regwrite;
    input wire logic mem_wb_regwrite;

    
    input wire logic id_ex_mem_read_en;

    input wire logic branch_taken;

    output logic pc_stall;
    output logic if_id_stall;
    output logic id_ex_stall;

    output logic if_id_bubble;
    output logic id_ex_bubble;
    output logic ex_mem_bubble;
    
    output forward_sel_t forward_rs1;
    output forward_sel_t forward_rs2;
    /*
    Load Use
        instruction[n] is a load instruction to load data d, instruction[n+1] uses data d
        data d is not available until write back. 
        stall instruction fetch, instructin decode and execute (pc, if_id_reg, id_ex_reg keeps previous value) when instruction[n] is in mem stage
        add NOP bubble into ex_mem_reg
        determine Load Use Hazard: rd in ex (id_ex_reg) matches rs1 or rs2 in id (if_id_reg) and id_ex_reg.mem_read_en is 1'b1
            need to delay 1 clock cycle
    */
    logic load_use_next;
    logic load_use;
    always_comb begin
        load_use_next = 1'b0;
        if(id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs1)
            if(id_ex_mem_read_en)
                load_use_next = 1'b1;
            else
                load_use_next = 1'b0;
        else
            load_use_next = 1'b0;
    end
    always_ff @(posedge clk) begin
        if(rst_n)
            load_use <= 1'b0;
        else 
            load_use <= load_use_next;
    end

    logic rst1_raw_hazard;
    logic rst2_raw_hazard;
    logic raw_hazard;
    assign raw_hazard = rst1_raw_hazard | rst2_raw_hazard;

    assign pc_stall = ((load_use || raw_hazard)) ? 1'b1 : 0;
    assign if_id_stall = ((load_use || raw_hazard) ) ? 1'b1 : 0;
    assign id_ex_stall = (load_use) ? 1'b1 : 0;
    assign if_id_bubble = (branch_taken) ? 1'b1 : 1'b0;
    assign ex_mem_bubble = (load_use) ? 1'b1 : 0;
    assign id_ex_bubble = (raw_hazard) ? 1'b1 : 0;
        // Need to forward when rd is written to and rd == rs1 and/or rd == rs2
    // If ex_rd == mem_rd, forward ex_rd value

    // Check to see if rs1 needs to be replaced with data from mem or wb
    always_comb begin
        forward_rs1 = FWD_NONE;
        rst1_raw_hazard = 1'b0;
       if (if_id_rs1 != 5'b0) begin
           if(if_id_rs1 == id_ex_rd && id_ex_mem_read_en)
            //    forward_rs1 = FWD_WB;
                rst1_raw_hazard = 1'b1;
           else if(if_id_rs1 == id_ex_rd && id_ex_regwrite)
            //    forward_rs1 = FWD_MEM;
                rst1_raw_hazard = 1'b1;
           else if (if_id_rs1 == ex_mem_rd && ex_mem_regwrite)
            //    forward_rs1 = FWD_WB;
                rst1_raw_hazard = 1'b1;
       end
    end
    
    // Check to see if rs2 needs to be replaced with data from mem or wb
    always_comb begin
        forward_rs2 = FWD_NONE;
        rst2_raw_hazard = 1'b0;
       if (if_id_rs2 != 5'b0) begin
           if(if_id_rs2 == id_ex_rd && id_ex_mem_read_en)
            //    forward_rs2 = FWD_WB;
               rst2_raw_hazard = 1'b1;
           if(if_id_rs2 == id_ex_rd && id_ex_regwrite)
            //    forward_rs2 = FWD_MEM;
               rst2_raw_hazard = 1'b1;
           else if (if_id_rs2 == ex_mem_rd && ex_mem_regwrite)
            //    forward_rs2 = FWD_WB;
               rst2_raw_hazard = 1'b1;
       end
    end

endmodule