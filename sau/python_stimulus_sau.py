import random
import cocotb
from cocotb.triggers import Timer
from osoc1_core_uarch import module_sau 

@cocotb.test()
async def automated_sau_test(dut):
    """Verify SAU using max/min boundaries across all alignments."""

    MAX_VAL = 0xFFFFFFFF
    MIN_VAL = 0x00000000

    # Test Matrix: (Description, Data, adrs_1, adrs_0, funct3)
    # funct3: 0=SB, 1=SH, 2=SW
    test_cases = [
        # --- Absolute Boundaries on Store Byte (SB) ---
        ("SB Max Val, Offset 0", MAX_VAL, 0, 0, 0),
        ("SB Max Val, Offset 3", MAX_VAL, 1, 1, 0), # Tests extreme left shift
        ("SB Min Val, Offset 2", MIN_VAL, 1, 0, 0),

        # --- Absolute Boundaries on Store Halfword (SH) ---
        ("SH Max Val, Offset 0", MAX_VAL, 0, 0, 1),
        ("SH Max Val, Offset 2", MAX_VAL, 1, 0, 1), # Max shift for SH
        ("SH Min Val, Offset 2", MIN_VAL, 1, 0, 1),

        # --- Absolute Boundaries on Store Word (SW) ---
        ("SW Max Val", MAX_VAL, 0, 0, 2),
        ("SW Min Val", MIN_VAL, 0, 0, 2),
    ]

    # Add Random Fuzzing
    for _ in range(10):
        test_cases.append((
            "Random Fuzz",
            random.randint(MIN_VAL, MAX_VAL),
            random.randint(0, 1),
            random.randint(0, 1),
            random.randint(0, 2)
        ))

    dut._log.info("Starting SAU Verification...")
    
    for desc, data, a1, a0, f3 in test_cases:
        # Drive pins
        dut.rd2_data_i.value = data
        dut.adrs_1_i.value = a1
        dut.adrs_0_i.value = a0
        dut.funct3_i.value = f3

        await Timer(1, unit="ns")

        # Get Golden Results
        exp_aligned, exp_mask = module_sau(data, a1, a0, f3)

        # Read Hardware
        hw_aligned = int(dut.aligned_data_o.value)
        hw_mask    = int(dut.byte_mask_o.value)

        # Mask Python output to 32 bits for clean comparison
        exp_aligned &= 0xFFFFFFFF

        assert hw_aligned == exp_aligned, f"DATA FAIL ({desc})! Exp: 0x{exp_aligned:08X} | Act: 0x{hw_aligned:08X}"
        assert hw_mask == exp_mask,       f"MASK FAIL ({desc})! Exp: {bin(exp_mask)} | Act: {bin(hw_mask)}"
        
        dut._log.info(f"PASS: {desc} | Mask: {bin(hw_mask)} | Data: 0x{hw_aligned:08X}")

    dut._log.info("SUCCESS: All SAU boundaries passed!")
