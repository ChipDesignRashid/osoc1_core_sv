// TODO: add datamem_we as input fromcontroller and AND this with byte_mask_o
//
module sau (
    input  logic [31:0] rd2_data_i,
    input  logic        adrs_1_i,
    input  logic        adrs_0_i,
    input  logic [2:0]  funct3_i,

    output logic [31:0] aligned_data_o,
    output logic [3:0]  byte_mask_o     // This is your 'dm_we'
);

    // Internal wires matching your schematic nodes
    logic [31:0] node_t;
    logic [31:0] node_u;

    // =========================================================================
    // 1. DATA PATH: The Cascaded Multiplexers
    // =========================================================================
    
    // First Mux (Controlled by adrs_1_i)
    // If adrs_1_i == 1, route the 16-bit left-shifted data. Else, route raw data.
    assign node_t = adrs_1_i ? (rd2_data_i << 16) : rd2_data_i;

    // Second Mux (Controlled by adrs_0_i)
    // If adrs_0_i == 1, route the 8-bit left-shifted 'T' data. Else, route 'T'.
    assign node_u = adrs_0_i ? (node_t << 8) : node_t;

    // Final Output Connection
    assign aligned_data_o = node_u;


    // =========================================================================
    // 2. CONTROL PATH: The 'dm_we' Logic Cloud
    // =========================================================================
    always_comb begin
        // Hardware default
        byte_mask_o = 4'b0000;

        case (funct3_i)
            // if func3 == sb
            3'b000: begin 
                case ({adrs_1_i, adrs_0_i})
                    2'b00: byte_mask_o = 4'b0001;
                    2'b01: byte_mask_o = 4'b0010;
                    2'b10: byte_mask_o = 4'b0100;
                    2'b11: byte_mask_o = 4'b1000;
                endcase
            end

            // if func3 == sh
            3'b001: begin 
 	    	// We must handle unaligned addresses to match Python's bitwise math!
                case ({adrs_1_i, adrs_0_i}) 
                    2'b00: byte_mask_o = 4'b0011; // Aligned Offset 0
                    2'b01: byte_mask_o = 4'b0110; // Unaligned Offset 1
                    2'b10: byte_mask_o = 4'b1100; // Aligned Offset 2
                    2'b11: byte_mask_o = 4'b1000; // Unaligned Offset 3 (Top bit chopped off)
	    	endcase
            end

            // if func3 == sw
            3'b010: begin 
                byte_mask_o = 4'b1111;
            end

            default: byte_mask_o = 4'b0000;
        endcase
    end

endmodule

