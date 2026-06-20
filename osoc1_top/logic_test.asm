# Test
addi x1, x0, 0x078
addi x2,x1, -2048
addi x3, x1,2047
lui x4, 0x7FFFF
lui x5, 0x80000
addi x8, zero, 0    # Initialize s0 (x8) FIRST
addi x6, s0, 4
addi x7, s0, -12
addi x8, zero, 0
addi x9, zero, 2032
addi x10, zero, -78
lui x11, 0xABCDE
addi x11, x11, 0x123
lui x12, 0xFEEDB
addi x12, x12, 0x987
lui  x13, 0xFFFFF      # x1 = 0xFFFFF000 (The top of the memory map)
addi x13, x13, 2047     # x1 = 0xFFFFF000 + 0x000007FF (Max positive 12-bit)
lui  x14, 0xFFFFF      # x1 = 0xFFFFF000
addi x14, x14, 0x800    # Wait! 0x800 is -2048
# Result: 0xFFFFE800 (We went backwards)
