module sau (
    input  logic        mem_we_i,   // NEW: Master Write Enable from Control Unit (1-bit)
    input  logic [31:0] rs2_val_i,  // Raw data to store
    input  logic        adrs_1_i,   // ALU result bit 1
    input  logic        adrs_0_i,   // ALU result bit 0
    input  logic [2:0]  f3_i,       // NEW: funct3 to decode sb/sh/sw

    output logic [31:0] wdata_o,    // Replicated data
    output logic [3:0]  strobe_o    // NEW: 4-bit Write Strobe for the memory
);

    logic [3:0] raw_strobe;

    always_comb begin
        // Default assignments to prevent inferred latches
        wdata_o    = rs2_val_i;
        raw_strobe = 4'b0000;

        case (f3_i)
            // -----------------------------------------------------------------
            // sb (Store Byte) - funct3: 3'b000
            // -----------------------------------------------------------------
            3'b000: begin 
                // Smear the lowest byte across all 4 lanes: { A, A, A, A }
                wdata_o = {4{rs2_val_i[7:0]}};
                
                // Shift a single '1' to the correct byte lane based on the address
                // Address 00 -> 0001
                // Address 01 -> 0010
                // Address 10 -> 0100
                // Address 11 -> 1000
                raw_strobe = 4'b0001 << {adrs_1_i, adrs_0_i};
            end

            // -----------------------------------------------------------------
            // sh (Store Halfword) - funct3: 3'b001
            // -----------------------------------------------------------------
            3'b001: begin 
                // Smear the lowest halfword across both halves: { AB, AB }
                wdata_o = {2{rs2_val_i[15:0]}};
                
                // If address bit 1 is high, write top half. Else write bottom half.
                raw_strobe = adrs_1_i ? 4'b1100 : 4'b0011;
            end

            // -----------------------------------------------------------------
            // sw (Store Word) - funct3: 3'b010
            // -----------------------------------------------------------------
            3'b010: begin 
                // Pass the full 32-bit word through untouched
                wdata_o = rs2_val_i;
                
                // Enable all 4 bytes
                raw_strobe = 4'b1111;
            end
            
            // Default catch-all
            default: begin
                wdata_o = rs2_val_i;
                raw_strobe = 4'b0000;
            end
        endcase
    end

    // =========================================================================
    // The Hardware Safety Gate
    // =========================================================================
    // If the instruction is NOT a store (mem_we_i is 0), force the strobe to 
    // 4'b0000 to absolutely guarantee we don't accidentally corrupt memory.
    assign strobe_o = mem_we_i ? raw_strobe : 4'b0000;

endmodule
