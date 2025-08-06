module RegisterFile(
        input wire logic clk,
        input wire logic rst_n,
        input wire logic[4:0] rs1,
        input wire logic[4:0] rs2,

        output logic[31:0] rs1_data,
        output logic[31:0] rs2_data,

        input wire logic[4:0] rd,
        input wire logic[31:0] rd_data,
        input wire logic write_enable

    );

    logic[31:0] registers[32] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

    always_comb
    begin
        rs1_data = (rs1 == 0) ? 32'b0 : (rs1 == rd) ? rd_data : registers[rs1];
        rs2_data = (rs2 == 0) ? 32'b0 : (rs2 == rd) ? rd_data : registers[rs2];
    end

    always_ff @(posedge clk)
    begin
//        if (rst_n == 1'b0)
//        begin
//            for(int i = 0; i < 32; i++)
//                registers[i] <= 32'b0;
//        end
//        else
            if (write_enable && rd != 0)
                registers[rd] <= rd_data;
    end

endmodule
