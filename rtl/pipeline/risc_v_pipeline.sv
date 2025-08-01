`timescale 1ns / 1ps
`default_nettype none

import rv32_pipeline_pkg::*;

module risc_v_pipeline(
        clk,
        rst_n,
        instruction,
        pc,
        mem_address,
        mem_write_data,
        mem_write_en,

        mem_read_data,
        mem_read_en
    );

    parameter PC_RESET_VALUE = 32'h00000000;

    input wire logic clk;
    input wire logic rst_n;
    input wire word_t instruction;
    output word_t pc;

    output word_t mem_address;
    output word_t mem_write_data;
    output logic mem_write_en;

    input wire word_t mem_read_data;
    output logic mem_read_en;

    // Instruction Fetch

    if_id_t if_id_reg;

    always_ff @(posedge clk) begin
        if(!rst_n)
            if_id_reg <= '0;
        else begin
            if_id_reg.instruction <= instruction;
            if_id_reg.pc <= pc;
        end
    end

    word_t pc_next;

    always_comb begin // Never take branches. Need logic to handle when discovered branch should have been taken
        pc_next = pc + 4;
    end

    always_ff @(posedge clk)
        if(!rst_n)
            pc <= PC_RESET_VALUE;
        else
            pc <= pc_next;

    // Instruction Decode

    instruction_decode_if id_if();

    assign id_if.instruction = if_id_reg.instruction;

    ALU_OPCODE alu_op;
    ALU_OPERAND_A_SRC alu_src_a_sel;
    ALU_OPERAND_B_SRC alu_src_b_sel;
    IMMEDIATE_SELECT imm_sel;
    logic write_back_sel;
    logic reg_write_en;

    logic id_mem_read_en;
    logic id_mem_write_en;

    PL_RV32_Controller controller(
        .clk(clk),
        .rst_n(rst_n),
        .id_if(id_if),
        .alu_op(alu_op),
        .alu_src_a_sel(alu_src_a_sel),
        .alu_src_b_sel(alu_src_b_sel),
        .imm_sel(imm_sel),
        .write_back_sel(write_back_sel),
        .mem_read_en(id_mem_read_en),
        .mem_write_en(id_mem_write_en),
        .reg_write_en(reg_write_en)
    );

    word_t rs1_data;
    word_t rs2_data;

    mem_wb_t mem_wb_reg;

    RegisterFile regFile(.clk(clk), .rst_n(rst_n), .rs1(id_if.rs1), .rs2(id_if.rs2), .rs1_data(rs1_data), .rs2_data(rs2_data), .rd(mem_wb_reg.rd), .rd_data(mem_wb_reg.reg_store_value), .write_enable(mem_wb_reg.regFile_we));

    word_t immediateValue;

    ImmediateExtander immedExtand(.instruction(if_id_reg.instruction), .immediateSelect(imm_sel), .immediateValue(immediateValue));

    id_ex_t id_ex_reg;

    always_ff @(posedge clk) begin
        if(!rst_n)
            id_ex_reg <= '0;
        else begin
            id_ex_reg.rs1 <= id_if.rs1;
            id_ex_reg.rs1_data <= rs1_data;
            id_ex_reg.rs2 <= id_if.rs2;
            id_ex_reg.rs2_data <= rs2_data;
            id_ex_reg.rd <= id_if.rd;

            id_ex_reg.immediateValue <= immediateValue;

            id_ex_reg.alu_code <= alu_op;
            id_ex_reg.operand_a_select <= alu_src_a_sel;
            id_ex_reg.operand_b_select <= alu_src_b_sel;
            
            
            id_ex_reg.regFile_we <= reg_write_en;
            id_ex_reg.mem_read_en <= id_mem_read_en;
            id_ex_reg.mem_write_en <= id_mem_write_en;
            id_ex_reg.write_back_sel <= write_back_sel;
        end
    end

    // Execute

    forward_sel_t fwd_rs1;
    forward_sel_t fwd_rs2;


    word_t alu_result;
    logic zero_result;

    word_t operand_a;
    word_t fwd_operand_a;
    word_t operand_b;
    word_t fwd_operand_b;


    ALU alu(.clk(clk), .rst_n(rst_n), .operand_a(operand_a), .operand_b(operand_b), .opcode(id_ex_reg.alu_code), .result(alu_result), .zero(zero_result));
    
    always_comb begin
        case(id_ex_reg.operand_a_select)
            REGISTER_A:
                operand_a = fwd_operand_a;
            default:
                operand_a = fwd_operand_a;
        endcase
    end

    always_comb begin
        case(fwd_rs1)
            FWD_NONE:
                fwd_operand_a = id_ex_reg.rs1_data;
            FWD_MEM:
                fwd_operand_a = ex_mem_reg.alu_result;
            FWD_WB:
                fwd_operand_a = mem_wb_reg.reg_store_value;
            default:
                fwd_operand_a = id_ex_reg.rs1_data;
        endcase
    end

    always_comb begin
        case(fwd_rs1)
            FWD_NONE:
                fwd_operand_b = id_ex_reg.rs2_data;
            FWD_MEM:
                fwd_operand_b = ex_mem_reg.alu_result;
            FWD_WB:
                fwd_operand_b = mem_wb_reg.reg_store_value;
            default:
                fwd_operand_b = id_ex_reg.rs2_data;
        endcase
    end

    always_comb begin
        case(id_ex_reg.operand_b_select)
            REGISTER_B:
                operand_b = fwd_operand_b;
            IMMEDIATE:
                operand_b = id_ex_reg.immediateValue;
            ZERO:
                operand_b = 32'b0;
            default:
                operand_b = fwd_operand_b;
        endcase
    end

    ex_mem_t ex_mem_reg;

    always_ff @(posedge clk) begin
        if(!rst_n)
            ex_mem_reg <= '0;
        else begin
            ex_mem_reg.alu_result <= alu_result;
            ex_mem_reg.regFile_we <= id_ex_reg.regFile_we;
            ex_mem_reg.rd <= id_ex_reg.rd;
            ex_mem_reg.mem_store_value <= id_ex_reg.rs2_data;
            ex_mem_reg.mem_write_en <= id_ex_reg.mem_write_en;
            ex_mem_reg.mem_read_en <= id_ex_reg.mem_read_en;

        end
    end

    // Memory

        word_t store_value;

        assign store_value = ex_mem_reg.alu_result;
        assign mem_address = ex_mem_reg.alu_result;
        assign mem_write_data = ex_mem_reg.mem_store_value;
        assign mem_write_en = ex_mem_reg.mem_write_en;
        assign mem_read_en = ex_mem_reg.mem_read_en;

        always_ff @(posedge clk) begin
            if(!rst_n)
                mem_wb_reg <= '0;
            else begin
                mem_wb_reg.reg_store_value <= store_value;
                mem_wb_reg.regFile_we <= ex_mem_reg.regFile_we;
                mem_wb_reg.rd <= ex_mem_reg.rd;
            end
        end

    // Write-Back

    Hazard_Unit hazard_unit(
        .id_rs1(id_ex_reg.rs1),
        .id_rs2(id_ex_reg.rs2),
        .mem_rd(ex_mem_reg.rd),
        .wb_rd(mem_wb_reg.rd),
        .mem_regwrite(ex_mem_reg.regFile_we),
        .wb_regwrite(mem_wb_reg.regFile_we),

        .forward_rs1(fwd_rs1),
        .forward_rs2(fwd_rs2)
        );
    
endmodule
