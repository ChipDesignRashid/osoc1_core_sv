import cpu_sv_package::*;

module alu #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] src1_i,
    input  logic [WIDTH-1:0] src2_i,
    input  alu_op_e          alu_op_i, // Using the package enum
    
    output logic [WIDTH-1:0] res_o,
    output logic             z_o,
    output logic             s_o,
    output logic             ovfl_o,
    output logic             carry_o
);

    // 33-bit wires to safely capture the Carry/Borrow bit
    logic [WIDTH:0] sum_res;
    logic [WIDTH:0] sub_res;

    logic [4:0] shamt;
    assign shamt = src2_i[4:0];

    // Explicit zero-extension
    assign sum_res = {1'b0, src1_i} + {1'b0, src2_i};
    assign sub_res = {1'b0, src1_i} - {1'b0, src2_i};

    always_comb begin
        res_o   = '0;
        carry_o = 1'b0;
        ovfl_o  = 1'b0;

        case (alu_op_i)
            ALU_ADD: begin 
                res_o   = sum_res[WIDTH-1:0];
                carry_o = sum_res[WIDTH]; 
                ovfl_o  = (src1_i[WIDTH-1] == src2_i[WIDTH-1]) & (res_o[WIDTH-1] != src1_i[WIDTH-1]);
            end
            ALU_SUB: begin 
                res_o   = sub_res[WIDTH-1:0];
                carry_o = ~sub_res[WIDTH]; 
                ovfl_o  = (src1_i[WIDTH-1] != src2_i[WIDTH-1]) & (res_o[WIDTH-1] != src1_i[WIDTH-1]);
            end
            ALU_SLT: begin 
                logic tmp_s_o, tmp_ovfl_o;
                tmp_s_o    = sub_res[WIDTH-1]; 
                tmp_ovfl_o = (src1_i[WIDTH-1] != src2_i[WIDTH-1]) & (sub_res[WIDTH-1] != src1_i[WIDTH-1]);
                res_o = { {(WIDTH-1){1'b0}}, (tmp_s_o ^ tmp_ovfl_o) };
            end
            ALU_SLTU: begin 
                res_o = { {(WIDTH-1){1'b0}}, sub_res[WIDTH] }; 
            end
            ALU_SLL: res_o = src1_i << shamt;
            ALU_SRL: res_o = src1_i >> shamt;
            ALU_SRA: res_o = $signed(src1_i) >>> shamt;
            ALU_XOR: res_o = src1_i ^ src2_i;
            ALU_OR:  res_o = src1_i | src2_i;
            ALU_AND: res_o = src1_i & src2_i;
            default: res_o = src2_i; 
        endcase

        z_o = (res_o == '0);
        s_o = res_o[WIDTH-1];
    end
endmodule

