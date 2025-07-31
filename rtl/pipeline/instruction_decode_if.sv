import rv32_pipeline_pkg::*;

interface instruction_decode_if;

  // Inputs
  logic [31:0] instruction;

  // Outputs
  logic [4:0] rs1;
  logic [4:0] rs2;
  logic [4:0] rd ;

  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [6:0] opcode;

  always_comb begin
    rs1 = instruction[RS1_MSB:RS1_LSB];
    rs2 = instruction[RS2_MSB:RS2_LSB];
    rd  = instruction[RD_MSB:RD_LSB];

    funct3 = instruction[FUNCT3_MSB:FUNCT3_LSB];
    funct7 = instruction[FUNCT7_MSB:FUNCT7_LSB];
    opcode = instruction[OPCODE_MSB:OPCODE_LSB];
  end

  modport input_side (input instruction, output rs1, rs2, rd);
  modport decode_side (input funct3, funct7, opcode);

endinterface //instruction_decode_if