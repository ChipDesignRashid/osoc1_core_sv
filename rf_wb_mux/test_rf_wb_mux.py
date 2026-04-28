import cocotb
from cocotb.triggers import Timer
import random

# --- 1. Your Python Golden Model (The Oracle) ---
def module_rf_wb_mux(alu_res_i, lau_res_i, pc_plus_4_i, d2r_sel_i):
    """
    RF Write-Back Mux (The Yellow Box)
    d2r_sel_i: 0=ALU, 1=LAU (Memory), 2=PC+4
    """
    if d2r_sel_i == 0:
        rf_wd_o = alu_res_i       # Path from ALU (Pink wire)
    elif d2r_sel_i == 1:
        rf_wd_o = lau_res_i       # Path from LAU (Brown wire)
    elif d2r_sel_i == 2:
        rf_wd_o = pc_plus_4_i     # Path from pc_plus_4 (Green wire)
    else:
        rf_wd_o = 0               # Safety/Default

    # Return the calculated value (we bypass the prints here to keep the log clean, 
    # but you can leave them in if you want verbose debugging!)
    return rf_wd_o

# --- 2. The Hardware Test ---
@cocotb.test()
async def golden_model_mux_test(dut):
    """Test the SV Mux using the Colab Python Oracle"""

    # We enforce strict Maximum (0xFFFFFFFF) and Minimum (0x00000000) boundary checks,
    # followed by completely randomized stress tests.
    test_vectors = [
        # (alu_res, lau_res, pc_plus_4, d2r_sel)
        
        # --- BOUNDARY CHECKS ---
        (0xFFFFFFFF, 0x00000000, 0x00000000, 0), # Max ALU
        (0x00000000, 0xFFFFFFFF, 0x00000000, 1), # Max LAU
        (0x00000000, 0x00000000, 0xFFFFFFFF, 2), # Max PC+4
        (0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 3), # Max Safety Default Check
        
        # --- RANDOMIZED STRESS CHECKS ---
        (random.randint(0, 0xFFFFFFFF), random.randint(0, 0xFFFFFFFF), random.randint(0, 0xFFFFFFFF), 0),
        (random.randint(0, 0xFFFFFFFF), random.randint(0, 0xFFFFFFFF), random.randint(0, 0xFFFFFFFF), 1),
        (random.randint(0, 0xFFFFFFFF), random.randint(0, 0xFFFFFFFF), random.randint(0, 0xFFFFFFFF), 2)
    ]

    for alu_val, lau_val, pc_val, sel_val in test_vectors:
        
        # 1. Ask the Python Oracle what the answer should be
        expected_rf_wd = module_rf_wb_mux(alu_val, lau_val, pc_val, sel_val)

        # 2. Drive the physical SystemVerilog silicon pins
        dut.alu_res_i.value = alu_val
        dut.lau_res_i.value = lau_val
        dut.pc_plus_4_i.value = pc_val
        dut.d2r_sel_i.value = sel_val
        
        # 3. Wait for the gates to physically switch
        await Timer(1, unit="ns")
        
        # 4. Check the silicon output against the Python Oracle
        actual_rf_wd = dut.rf_wd_o.value
        
        assert actual_rf_wd == expected_rf_wd, \
            f"MISMATCH! Sel:{sel_val} | Oracle wanted: {hex(expected_rf_wd)}, Silicon gave: {hex(actual_rf_wd)}"
        
        dut._log.info(f"Verified Path {sel_val} -> Output: {hex(actual_rf_wd)}")
