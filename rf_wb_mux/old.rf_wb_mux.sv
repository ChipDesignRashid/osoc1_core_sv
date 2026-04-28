// rf_wb_mux.sv
module rf_wb_mux (
    input  logic [31:0] alu_res_i,
    input  logic [31:0] lau_res_i,
    input  logic [31:0] pc_plus_4_i,
    input  logic [1:0]  d2r_sel_i,
    output logic [31:0] rf_wd_o
);

    always_comb begin
        case (d2r_sel_i)
            2'b00:   rf_wd_o = alu_res_i;
            2'b01:   rf_wd_o = lau_res_i;
            2'b10:   rf_wd_o = pc_plus_4_i;
            default: rf_wd_o = 32'h0; // Safety default
        endcase
    end

endmodule
