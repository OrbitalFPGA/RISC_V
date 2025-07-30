import rv32_pipeline_pkg::*;

module ImmediateExtander (
        input wire logic[31:0] instruction,
        input wire IMMEDIATE_SELECT immediateSelect,  // select immediate type
        output logic[31:0] immediateValue
    );


    always_comb
    begin
        case(immediateSelect)
            I_TYPE: // imm[11:0] = instruction[31:20]
                immediateValue = {{20{instruction[31]}}, instruction[31:20]};
            S_TYPE: // imm[11:5]   = instruction[31:25], imm[4:0] = instruction[11:7]
                immediateValue = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            B_TYPE: // imm[12|10:5|4:1|11] = instruction[31|30:25|11:8|7], <<1
                immediateValue = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            U_TYPE: // imm[31:12] = instruction[31:12], imm[11:0] = 0
                immediateValue = {instruction[31:12], 12'b0};
            J_TYPE: // imm[20|10:1|11|19:12] = instruction[31|30:21|20|19:12], <<1
                immediateValue =  {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default:
                immediateValue = 32'b0;

        endcase
    end

endmodule
