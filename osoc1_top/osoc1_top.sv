import cpu_sv_package::*;

module osoc1_top #(
    parameter int IMEM_DEPTH = 1024,
    parameter int DMEM_DEPTH = 1024
)(
    input logic clk_i,
    input logic rst_ni
);

    logic [31:0] core_pc_to_imem;
    logic [31:0] imem_instr_to_core;

    logic [3:0]  core_dmem_we;
    logic [31:0] core_dmem_addr;
    logic [31:0] core_dmem_wdata;
    logic [31:0] dmem_rdata_to_core;

    osoc1_cpu_core u_cpu_core (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .pc_o           (core_pc_to_imem),
        .instr_i        (imem_instr_to_core),
        .dmem_we_o      (core_dmem_we),
        .dmem_addr_o    (core_dmem_addr),
        .dmem_wdata_o   (core_dmem_wdata),
        .dmem_rdata_i   (dmem_rdata_to_core)
    );

    instr_mem_wrapper #(.DEPTH(IMEM_DEPTH)) u_instr_mem (
        .clk_i          (clk_i),
        .pc_i           (core_pc_to_imem),
        .instr_o        (imem_instr_to_core)
    );

    data_mem_wrapper #(.DEPTH(DMEM_DEPTH)) u_data_mem (
        .clk_i          (clk_i),
        .we_i           (core_dmem_we),
        .addr_i         (core_dmem_addr),
        .wd_i           (core_dmem_wdata),
        .rd_o           (dmem_rdata_to_core)
    );

endmodule
