// File location: osoc1_sim/common/cpu_pkg.sv

package cpu_sv_package;

    // The strongly-typed Enum for Write-Back Mux selection
    typedef enum logic [1:0] {
        SEL_ALU = 2'b00,
        SEL_LAU = 2'b01,
        SEL_PC4 = 2'b10
    } wb_sel_e;

    // You will eventually add ALU opcodes, PC states, and 
    // instruction types to this exact same file!

    // ALU Operand A Mux Enum (2-bit)
    typedef enum logic [1:0] {
        OP_A_PC   = 2'b00,
        OP_A_RS1  = 2'b01,
        OP_A_ZERO = 2'b10
    } sel_alu_a_e;

    // ALU Operand B Mux Enum (1-bit)
    typedef enum logic {
        OP_B_RS2 = 1'b0,
        OP_B_IMM = 1'b1
    } sel_alu_b_e;

endpackage



