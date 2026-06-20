# =========================================================================
# U-TYPE AUIPC BOUNDARY & PC ALIGNMENT TEST
# =========================================================================

# Assuming execution begins at PC = 0x00000000

# 1. The Minimum Boundary Check (Immediate = 0)
# Execution PC = 0
auipc x20, 0             # x20 = 0 + (0 << 12) = 0x00000000

# 2. Standard Shift Check (Immediate = 1)
# Execution PC = 4
auipc x21, 1             # x21 = 4 + (1 << 12) = 0x00001004 (4100)

# 3. The Maximum Boundary Check (Immediate = 0xFFFFF)
# Execution PC = 8
# 0xFFFFF << 12 = 0xFFFFF000 (which is -4096 in 32-bit signed space)
auipc x22, 0xFFFFF       # x22 = 8 + 0xFFFFF000 = 0xFFFFF008 (-4088)
