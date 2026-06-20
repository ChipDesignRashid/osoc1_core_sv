# =========================================================================
# I-TYPE ALU DATAPATH TEST
# =========================================================================

# --- SETUP PHASE ---
addi x1, zero, 12       # x1 = 12 (Binary: 1100)
addi x2, zero, -16      # x2 = -16 (0xFFFFFFF0)

# --- EXECUTION PHASE ---
# 1. Bitwise Immediate
xori x20, x1, -1        # x20 = 12 ^ -1 (Bitwise NOT). Expected: -13 (0xFFFFFFF3)
ori  x21, x1, 2         # x21 = 12 | 2. Expected: 14 (0x0000000E)
andi x22, x1, 8         # x22 = 12 & 8. Expected: 8 (0x00000008)

# 2. Shift Immediate
slli x23, x1, 2         # x23 = 12 << 2. Expected: 48 (0x00000030)
srli x24, x2, 4         # x24 = -16 >> 4 (Logical). Expected: 0x0FFFFFFF
srai x25, x2, 4         # x25 = -16 >> 4 (Arithmetic). Expected: -1 (0xFFFFFFFF)

# 3. Compare Immediate
slti x26, x1, 10        # x26 = (12 < 10) ? 1 : 0. Expected: 0
