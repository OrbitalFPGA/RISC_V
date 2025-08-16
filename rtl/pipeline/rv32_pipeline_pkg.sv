package rv32_pipeline_pkg;
  // Stages
  // Fetch IF
  // Decode ID
  // Execute EX
  // Memory MEM
  // Write back WB

  // Common opcode location (all types)
  localparam int OPCODE_LSB = 0;
  localparam int OPCODE_MSB = 6;

  // funct3 is always in bits [14:12]
  localparam int FUNCT3_LSB = 12;
  localparam int FUNCT3_MSB = 14;

  // funct7 is in bits [31:25] for R-type instructions
  localparam int FUNCT7_LSB = 25;
  localparam int FUNCT7_MSB = 31;

  // rd is always [11:7], rs1 is [19:15], rs2 is [24:20]
  localparam int RD_LSB = 7 ;
  localparam int RD_MSB = 11;

  localparam int RS1_LSB = 15;
  localparam int RS1_MSB = 19;

  localparam int RS2_LSB = 20;
  localparam int RS2_MSB = 24;

  typedef enum logic[3:0] {
    ALU_ADD    = 4'b0000,
    ALU_SUB    = 4'b0001,
    ALU_SLL    = 4'b0010, // Shift left
    ALU_SRL    = 4'b0011, // Logical shift right
    ALU_SRA    = 4'b0100, // Arithmetic shift right
    ALU_XOR    = 4'b0101,
    ALU_OR     = 4'b0110,
    ALU_AND    = 4'b0111,
    ALU_SLT    = 4'b1000,
    ALU_SLTU   = 4'b1001,
    ALU_PASS_B = 4'b1010
  } ALU_OPCODE;

  typedef enum logic {
    REGISTER_A  = 1'b0,
    PC_REGISTER = 1'b1
  } ALU_OPERAND_A_SRC;

  typedef enum logic[2:0] {
    REGISTER_B = 3'b000,
    IMMEDIATE  = 3'b001,
    PC_DEFAULT = 3'b010,
    CSR        = 3'b011,
    ZERO       = 3'b100
  } ALU_OPERAND_B_SRC;

  typedef enum logic[2:0] {
    I_TYPE = 3'b000,
    S_TYPE = 3'b001,
    B_TYPE = 3'b010,
    U_TYPE = 3'b011,
    J_TYPE = 3'b100
  } IMMEDIATE_SELECT;

  typedef enum logic[6:0] {
    MEM_LOAD_OP  = 7'b0000011,
    MEM_STORE_OP = 7'b0100011,
    IMMED_ARITH  = 7'b0010011,
    ARITH        = 7'b0110011,
    BRANCH       = 7'b1100011,
    JALR         = 7'b1100111,
    JAL          = 7'b1101111,
    SYSTEM       = 7'b1110011,
    LUI          = 7'b0110111,
    AUIPC        = 7'b0010111
  } OPCODE_DECODE;

  typedef struct packed {
    logic [31:0] instruction;
    logic [31:0] pc         ;
  } if_id_t;

  typedef logic [4:0] reg_addr_t;
  typedef logic [31:0] word_t;

    typedef enum logic [1:0] {
      FWD_NONE = 2'b00,
      FWD_MEM  = 2'b01,
      FWD_WB   = 2'b10
  } forward_sel_t;

  typedef struct packed {
    word_t            rs1_data        ;
    word_t            rs2_data        ;
    word_t            immediateValue  ;
    reg_addr_t        rs1             ;
    reg_addr_t        rs2             ;
    reg_addr_t        rd;
    ALU_OPCODE        alu_code        ;
    ALU_OPERAND_A_SRC operand_a_select;
    ALU_OPERAND_B_SRC operand_b_select;
    logic             regFile_we      ;
    logic             mem_read_en     ;
    logic             mem_write_en    ;
    logic             write_back_sel  ;
    forward_sel_t     fwd_rs1;
    forward_sel_t     fwd_rs2; 
    word_t instruction;

    logic branch_taken;
    word_t branch_pc;

    logic eq;
    logic lt;
    logic ltu;
    logic [2:0] funct3;
    logic is_branch;

  } id_ex_t;

  typedef struct packed {
    word_t      alu_result;
    word_t      mem_store_value;
    logic             mem_read_en     ;
    logic             mem_write_en    ;
    logic       regFile_we;
    reg_addr_t  rd;
    word_t instruction;

  } ex_mem_t;

  typedef struct packed {
    word_t      reg_store_value;
    logic       regFile_we;
    reg_addr_t  rd;
    word_t instruction;

  } mem_wb_t;



endpackage
