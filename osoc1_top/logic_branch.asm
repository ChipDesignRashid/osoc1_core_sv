# =========================================================================
# B-TYPE: COMPREHENSIVE BRANCH CONTROL UNIT TEST
# =========================================================================

# --- SETUP PHASE (Testing Max/Min Boundaries) ---
addi x1, zero, 10       # x1 = 10
addi x2, zero, 10       # x2 = 10
addi x3, zero, -2048    # x3 = -2048 (0xFFFFF800 - Minimum boundary)
addi x4, zero, 2047     # x4 = 2047  (0x000007FF - Maximum boundary)

# Initialize our result registers to 1 (Assuming PASS)
addi x20, zero, 1
addi x21, zero, 1
addi x22, zero, 1
addi x23, zero, 1
addi x24, zero, 1
addi x25, zero, 1

# --- EXECUTION: TAKEN BRANCH TESTS (Should Skip 8 bytes) ---

# 1. BEQ (Equal): 10 == 10
beq  x1, x2, 8
addi x20, zero, 0       # FAIL: Overwrites with 0 if branch missed

# 2. BNE (Not Equal): -2048 != 2047
bne  x3, x4, 8
addi x21, zero, 0       # FAIL: Overwrites with 0 if branch missed

# 3. BLT (Less Than Signed): -2048 < 10
blt  x3, x1, 8
addi x22, zero, 0       # FAIL: Overwrites with 0 if branch missed

# 4. BGE (Greater/Equal Signed): 2047 >= 10
bge  x4, x1, 8
addi x23, zero, 0       # FAIL: Overwrites with 0 if branch missed

# 5. BLTU (Less Than Unsigned)
# -2048 in hardware is 0xFFFFF800. Unsigned, this is 4,294,965,248.
# Therefore, 10 < 4,294,965,248 is TRUE.
bltu x1, x3, 8
addi x24, zero, 0       # FAIL: Overwrites with 0 if branch missed

# 6. BGEU (Greater/Equal Unsigned)
# 4,294,965,248 >= 10 is TRUE.
bgeu x3, x1, 8
addi x25, zero, 0       # FAIL: Overwrites with 0 if branch missed

# --- EXECUTION: NOT TAKEN TEST (Should Fall Through) ---
# We must also prove the CPU doesn't jump when the condition is FALSE.
addi x26, zero, 0       # Initialize to 0 (Assume FAIL)
beq  x1, x4, 8          # 10 == 2047? FALSE. It should fall through!
addi x26, zero, 1       # PASS: Overwrites with 1 because it correctly fell through
