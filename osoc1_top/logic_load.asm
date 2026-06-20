# =========================================================================
# THE ULTIMATE LOAD ALIGNMENT TEST (LAU)
# =========================================================================

# --- SETUP PHASE ---
addi x10, zero, 200      # x10 = 200 (Our Base Address)

# We are going to build the word: 0x3CA5A53C
addi x1, zero, 60        # x1 = 0x3C
addi x2, zero, -91       # x2 = 0xA5 (Sign-extended)

sb x1, 0(x10)            # Mem[200] = 0x3C
sb x2, 1(x10)            # Mem[201] = 0xA5
sb x2, 2(x10)            # Mem[202] = 0xA5
sb x1, 3(x10)            # Mem[203] = 0x3C

# --- EXECUTION PHASE ---

# 1. Byte Extractions at Address 201 (The 0xA5 byte)
lb   x20, 1(x10)         # Sign-extend 0xA5. Expected: 0xFFFFFFA5 (-91)
lbu  x21, 1(x10)         # Zero-extend 0xA5. Expected: 0x000000A5 (165)

# 2. Byte Extractions at Address 200 (The 0x3C byte)
lb   x22, 0(x10)         # Sign-extend 0x3C. Expected: 0x0000003C (60)
lbu  x23, 0(x10)         # Zero-extend 0x3C. Expected: 0x0000003C (60)

# 3. Halfword Extractions (Little-Endian: Mem[1] | Mem[0] -> 0xA53C)
lh   x24, 0(x10)         # Sign-extend 0xA53C. Expected: 0xFFFFA53C (-23236)
lhu  x25, 0(x10)         # Zero-extend 0xA53C. Expected: 0x0000A53C (42300)

# 4. The Full Word Extraction
lw   x26, 0(x10)         # Pass through. Expected: 0x3CA5A53C (1017488700)
