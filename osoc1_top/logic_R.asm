# =========================================================================
# THE ULTIMATE R-TYPE DATAPATH TEST
# =========================================================================

# --- SETUP PHASE ---
# Loading our test operands into the lower registers
addi x1, zero, 12       # x1 = 12 (0x0000000C, Binary: 1100)
addi x2, zero, 10       # x2 = 10 (0x0000000A, Binary: 1010)
addi x3, zero, -4       # x3 = -4 (0xFFFFFFFC) - The Negative Test Subject
addi x4, zero, 2        # x4 = 2  - Our Shift Amount

# --- EXECUTION PHASE: R-TYPE OPERATIONS ---

# 1. Arithmetic (Add / Sub)
add  x20, x1, x2        # x20 = 12 + 10 = 22 (0x16)
sub  x21, x1, x2        # x21 = 12 - 10 = 2  (0x02)

# 2. Bitwise Logic (And / Or / Xor)
and  x22, x1, x2        # x22 = 1100 & 1010 = 1000 -> 8  (0x08)
or   x23, x1, x2        # x23 = 1100 | 1010 = 1110 -> 14 (0x0E)
xor  x24, x1, x2        # x24 = 1100 ^ 1010 = 0110 -> 6  (0x06)

# 3. Barrel Shifter Tests (Logical vs Arithmetic)
sll  x25, x1, x4        # x25 = 12 << 2 = 48 (0x30)
srl  x26, x3, x4        # x26 = (0xFFFFFFFC) >> 2 (Logical, pulls 0s) = 0x3FFFFFFF
sra  x27, x3, x4        # x27 = (-4) >> 2 (Arithmetic, pulls 1s) = -1 (0xFFFFFFFF)

# 4. The Comparator Tests (Signed vs Unsigned)
slt  x28, x3, x1        # x28 = (-4 < 12) Signed? True -> 1 (0x01)
sltu x29, x3, x1        # x29 = (0xFFFFFFFC < 12) Unsigned? False -> 0 (0x00)
