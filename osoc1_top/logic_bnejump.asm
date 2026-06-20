# =========================================================================
# TURING COMPLETENESS TEST: THE WHILE LOOP
# =========================================================================

# --- SETUP ---
addi x5, zero, 5      # x5 = 5 (Our loop counter)
addi x6, zero, 0      # x6 = 0 (Our running total)

# --- THE LOOP ---
# Memory Address 0x08 (Assuming execution started at 0x00)
add  x6, x6, x5       # total = total + counter
addi x5, x5, -1       # counter = counter - 1
bne  x5, zero, -8     # IF counter != 0, Jump back 8 bytes (2 instructions) to 0x08!

# --- END ---
# When the loop breaks, the CPU lands here.
addi x7, zero, 99     # x7 = 99 (Marker to prove we escaped the loop)
