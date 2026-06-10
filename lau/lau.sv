module lau (
    input  logic [31:0] mem_data_i,
    input  logic        adrs_1_i,
    input  logic        adrs_0_i,
    input  logic [2:0]  funct3_i,

    output logic [31:0] aligned_data_o
);

    // Internal wires matching your schematic nodes
    logic [31:0] stage1_mux_out;
    logic [31:0] stage2_mux_out;

    // =========================================================================
    // 1. DATA PATH: The Cascaded Right-Shift Multiplexers
    // =========================================================================
    
    // First Mux (Controlled by adrs_1_i)
    // If adrs_1_i == 1, shift right by 16 (16 zeros come in from the top)
    assign stage1_mux_out = adrs_1_i ? (mem_data_i >> 16) : mem_data_i;

    // Second Mux (Controlled by adrs_0_i)
    // If adrs_0_i == 1, shift right by 8 (8 more zeros come in)
    assign stage2_mux_out = adrs_0_i ? (stage1_mux_out >> 8) : stage1_mux_out;


    // =========================================================================
    // 2. MASK UNIT & SIGN EXTENSION (SE)
    // =========================================================================
    always_comb begin
        // Hardware default to prevent latches
        aligned_data_o = '0;

        case (funct3_i)
            // lb (Load Byte - Signed)
            3'b000: begin 
                // Mask to 8 bits, duplicate the 7th bit 24 times
                aligned_data_o = { {24{stage2_mux_out[7]}}, stage2_mux_out[7:0] };
            end

            // lh (Load Halfword - Signed)
            3'b001: begin 
                // Mask to 16 bits, duplicate the 15th bit 16 times
                aligned_data_o = { {16{stage2_mux_out[15]}}, stage2_mux_out[15:0] };
            end

            // lw (Load Word)
            3'b010: begin 
                aligned_data_o = stage2_mux_out;
            end

            // lbu (Load Byte - Unsigned)
            3'b100: begin 
                // Zero-extend the bottom 8 bits
                aligned_data_o = { 24'b0, stage2_mux_out[7:0] };
            end

            // lhu (Load Halfword - Unsigned)
            3'b101: begin 
                // Zero-extend the bottom 16 bits
                aligned_data_o = { 16'b0, stage2_mux_out[15:0] };
            end

            default: aligned_data_o = '0;
        endcase
    end

endmodule
