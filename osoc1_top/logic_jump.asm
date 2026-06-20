# =========================================================================
# THE FINAL MILESTONE: JAL & JALR (Function Calls)
# =========================================================================

# --- MAIN PROGRAM ---
# PC = 0x00
addi x5, zero, 15       # x5 = 15 (Our input)

# PC = 0x04
# Call the function at 0x10 (Offset = 12 bytes)
# Saves return address (0x08) into x1
jal  x1, 12

# PC = 0x08 (The Return Point)
addi x6, zero, 99       # x6 = 99 (Marker to prove we returned!)

# PC = 0x0C
beq  zero, zero, 0      # Infinite loop to stay at 0x0C (Stop execution)

# --- FUNCTION: DOUBLE IT ---
# PC = 0x10
add  x5, x5, x5         # x5 = 15 + 15 = 30

# PC = 0x14
# Jump back to the address in x1 (0x08)
jalr x0, 0(x1)
