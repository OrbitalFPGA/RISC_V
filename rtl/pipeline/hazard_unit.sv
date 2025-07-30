import rv32_pipeline_pkg::*;

module Hazard_Unit (
    id_rs1,
    id_rs2,
    mem_rd,
    wb_rd,
    mem_regwrite,
    wb_regwrite,

    forward_rs1,
    forward_rs2
    // input  wire reg_addr_t  id_rs1,
    // input  wire reg_addr_t  id_rs2,
    // input  wire reg_addr_t  ex_rd,
    // input  logic            ex_regwrite,
    // input  wire reg_addr_t  mem_rd,
    // input  logic            mem_regwrite,
    // input  logic            ex_mem_read,  // for load-use hazard
    // output logic            stall,
    // output logic            forward_mem_data,
    // output logic            forward_wb_data,

    // input word_t            mem_rd_data;
    // input word_t            wb_rd_data; 
);

    input wire reg_addr_t id_rs1;
    input wire reg_addr_t id_rs2;
    input wire reg_addr_t mem_rd;
    input wire reg_addr_t wb_rd;

    input wire logic mem_regwrite;
    input wire logic wb_regwrite;

    input wire logic mem_read;

    output forward_sel_t forward_rs1;
    output forward_sel_t forward_rs2;
    

    // Need to forward when rd is written to and rd == rs1 and/or rd == rs2
    // If mem_rd == wb_rd, forward mem_rd value

    // Check to see if rs1 needs to be replaced with data from mem or wb
    always_comb begin
        forward_rs1 = FWD_NONE;
        if (id_rs1 != 5'b0) begin
            if(id_rs1 == mem_rd && mem_regwrite)
                forward_rs1 = FWD_MEM;
            else if (id_rs1 == wb_rd && wb_regwrite)
                forward_rs1 = FWD_WB;
        end
    end
    
    // Check to see if rs2 needs to be replaced with data from mem or wb
    always_comb begin
        forward_rs2 = FWD_NONE;
        if (id_rs2 != 5'b0) begin
            if(id_rs2 == mem_rd && mem_regwrite)
                forward_rs2 = FWD_MEM;
            else if (id_rs2 == wb_rd && wb_regwrite)
                forward_rs2 = FWD_WB;
        end
    end


endmodule