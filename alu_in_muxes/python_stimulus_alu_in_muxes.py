import random
import cocotb
from cocotb.triggers import Timer
from osoc1_core_uarch import module_alu_in_muxes
# Import both the module and the global utility!
from osoc1_core_uarch import module_alu_in_muxes, get_max

# ==============================================================================
# AUTOMATED RANDOM VERIFICATION
# ==============================================================================
@cocotb.test()
async def automated_alu_in_muxes_test(dut):
    """Verify alu_in_muxes using max/min boundaries and random inputs."""
    
    # Define the exact maximums for our specific wire widths
    MAX_32 = get_max(32) # 0xFFFFFFFF
    MAX_2  = get_max(2)  # 3 (2'b11)
    MAX_1  = get_max(1)  # 1 (1'b1)
    MIN_VAL = 0
    # Step A: Mandatory Maximum and Minimum Boundary Checks
    # Formatted for: (pc_curr_i, rs1_val_i, rs2_val_i, imm_i, s1_sel_i, s2_sel_i)
    # Now we automatically drive every single pin to its absolute physical limit!
    test_cases = [
        # Test 1: Every single pin at absolute zero
        (MIN_VAL, MIN_VAL, MIN_VAL, MIN_VAL, MIN_VAL, MIN_VAL),
        
        # Test 2: Every single pin at its maximum physical wire capacity
        (MAX_32, MAX_32, MAX_32, MAX_32, MAX_2, MAX_1) 
    ]    
    # Step B: Constrained Random Vectors
    NUM_RANDOM_TESTS = 10
    for _ in range(NUM_RANDOM_TESTS):
        test_cases.append((
            random.randint(MIN_VAL, MAX_32), # pc_curr_i
            random.randint(MIN_VAL, MAX_32), # rs1_val_i
            random.randint(MIN_VAL, MAX_32), # rs2_val_i
            random.randint(MIN_VAL, MAX_32), # imm_i
            random.randint(MIN_VAL, MAX_2),  # s1_sel_i (Randomizes 0, 1, 2, and 3)
            random.randint(MIN_VAL, MAX_1)   # s2_sel_i (Randomizes 0 and 1)
        ))

    dut._log.info("Starting alu_in_muxes Verification...")
    dut._log.info("-" * 80)

    # Step C: The Execution Engine
    for pc_curr_i, rs1_val_i, rs2_val_i, imm_i, s1_sel_i, s2_sel_i in test_cases: 
        
        # 1. Auto-Generated Hardware Pin Driving
        dut.pc_curr_i.value = pc_curr_i
        dut.rs1_val_i.value = rs1_val_i
        dut.rs2_val_i.value = rs2_val_i
        dut.imm_i.value = imm_i
        dut.s1_sel_i.value = s1_sel_i
        dut.s2_sel_i.value = s2_sel_i
        
        # 2. Wait for propagation
        await Timer(1, unit="ns")
        
        # 3. Ask Golden Oracle
        expected_results = module_alu_in_muxes(pc_curr_i, rs1_val_i, rs2_val_i, imm_i, s1_sel_i, s2_sel_i)
        exp_a, exp_b = expected_results
        
        # 4. Read Hardware Pins (TODO: Update with your exact output pins)
        act_a = int(dut.alu_a_o.value)
        act_b = int(dut.alu_b_o.value)
        
        # 5. Log Output 
        
        # 6. Check Results (TODO: Adjust if Oracle returns a tuple of multiple outputs)
        assert act_a == exp_a, f"FAIL MUX A! Expected: {exp_a} | Actual: {act_a}"
        assert act_b == exp_b, f"FAIL MUX B! Expected: {exp_b} | Actual: {act_b}"
    dut._log.info("-" * 80)
    dut._log.info("SUCCESS: Boundary and random tests passed for alu_in_muxes!")
