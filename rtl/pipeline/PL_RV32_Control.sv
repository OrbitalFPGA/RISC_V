import rv32_pipeline_pkg::*;

module PL_RV32_Controller(
        clk,
        rst_n,
        id_if,
        reg_write_en,
        mem_read_en,
        mem_write_en,
        alu_op,
        alu_src_a_sel,
        alu_src_b_sel,
        imm_sel,
        write_back_sel,
        mem_addr_en,
        store_data_en,
        is_branch,
        funct3,
        csr_addr,
        csr_write_en,
        csr_illegal_access
    );

    input wire logic clk;
    input wire logic rst_n;
    instruction_decode_if.decode_side id_if;
    output logic reg_write_en;
    output logic mem_read_en;
    output logic mem_write_en;
    output ALU_OPCODE alu_op;
    output ALU_OPERAND_A_SRC alu_src_a_sel;
    output ALU_OPERAND_B_SRC alu_src_b_sel;
    output IMMEDIATE_SELECT imm_sel;
    output logic write_back_sel;
    output logic mem_addr_en;
    output logic store_data_en;

    output logic [11:0] csr_addr;
    output logic csr_write_en;
    input wire logic csr_illegal_access;

    output logic is_branch;
    output logic funct3;

    assign funct3 = id_if.funct3;
    assign is_branch = (id_if.opcode == BRANCH) ? 1'b1 : 1'b0;

    always_comb
    begin
        imm_sel = I_TYPE;
        case(id_if.opcode)
            MEM_LOAD_OP:
                imm_sel = I_TYPE;
            IMMED_ARITH:
                imm_sel = I_TYPE;
            BRANCH:
                imm_sel = B_TYPE;
            JAL:
                imm_sel = J_TYPE;
            JALR:
                imm_sel = I_TYPE;
            MEM_STORE_OP:
                imm_sel = S_TYPE;
            LUI:
                imm_sel = U_TYPE;
            AUIPC:
                imm_sel = U_TYPE;
        endcase
    end

    always_comb
    begin
        alu_src_a_sel = REGISTER_A;
        case(id_if.opcode)
            IMMED_ARITH:
                alu_src_a_sel = REGISTER_A;
        endcase
    end

    // assign alu_src_b_sel = IMMEDIATE;
    always_comb
    begin
        alu_src_b_sel = IMMEDIATE;
        case(id_if.opcode)
            ARITH:
                alu_src_b_sel = REGISTER_B;
            default:
                alu_src_b_sel = IMMEDIATE;
        endcase
    end

    ALU_OPCODE arithmetic_opcode;

    always_comb begin
        case (id_if.funct3)
            3'h0:
                arithmetic_opcode = ALU_ADD;
            3'h1:
                if (id_if.funct7 == 7'h0)
                    arithmetic_opcode = ALU_SLL;
            3'h2:
                arithmetic_opcode = ALU_SLT;
            3'h3:
                arithmetic_opcode = ALU_SLTU;
            3'h4:
                arithmetic_opcode = ALU_XOR;
            3'h5:
                if(id_if.funct7 == 7'h0)
                    arithmetic_opcode = ALU_SRL;
                else if(id_if.funct7 == 7'h20)
                    arithmetic_opcode = ALU_SRA;
            3'h6:
                arithmetic_opcode = ALU_OR;
            3'h7:
                arithmetic_opcode = ALU_AND;
            default: arithmetic_opcode = ALU_ADD;
        endcase
    end

    always_comb begin
        case(id_if.opcode)
            MEM_STORE_OP:
                alu_op = ALU_ADD;
            MEM_STORE_OP:
                alu_op = ALU_ADD;
            ARITH:
                alu_op = arithmetic_opcode;
            IMMED_ARITH:
                alu_op = arithmetic_opcode;
            LUI:
                alu_op = ALU_PASS_B;
            default
                alu_op = ALU_ADD;
        endcase
    end

    assign mem_read_en =  (id_if.opcode == MEM_LOAD_OP ) ? 1'b1 : 1'b0;
    assign mem_write_en = (id_if.opcode == MEM_STORE_OP) ? 1'b1 : 1'b0;

    assign write_back_sel = (id_if.opcode == MEM_LOAD_OP ) ? 1'b1 : 1'b0;
    assign reg_write_en = (id_if.opcode == MEM_LOAD_OP || id_if.opcode == IMMED_ARITH || id_if.opcode == LUI) ? 1'b1 : 1'b0;
    always_comb begin
        case(id_if.opcode)
            MEM_LOAD_OP:
                reg_write_en = 1'b1;
            ARITH:
                reg_write_en = 1'b1;
            IMMED_ARITH:
                reg_write_en = 1'b1;
            LUI:
                reg_write_en = 1'b1;
        endcase
    end


endmodule
