# =========================================================================
# S-TYPE STORE ALIGNMENT TEST (SAU)
# =========================================================================

# --- SETUP PHASE ---
addi x10, zero, 300      # x10 = 300 (Our Base Memory Address)

# Update these three lines to match the new expectations:
addi x1, zero, -1        # x1 = 0xFFFFFFFF (Fill with 1s)
addi x2, zero, 0x55      # x2 = 0x00000055 (Byte: 85. Well within max 2047)
addi x3, zero, 0x777     # x3 = 0x00000777 (Halfword: 1911. Well within max 2047)

# --- EXECUTION PHASE ---

# 1. Store the full word
sw   x1, 0(x10)          # Mem[300] = 0xFFFFFFFF. Strobe should be 1111.

# 2. Overwrite the top halfword (Bytes 2 and 3)
# We store at address 300 + 2. The SAU should generate strobe 1100.
sh   x3, 2(x10)          # Mem[300] becomes 0x0888FFFF

# 3. Overwrite Byte 1
# We store at address 300 + 1. The SAU should generate strobe 0010.
sb   x2, 1(x10)          # Mem[300] becomes 0x088877FF

# --- VERIFICATION PHASE ---
# Load the full word back out to prove the bytes merged correctly
lw   x20, 0(x10)         # x20 should perfectly equal 0x088877FF (143161343)
