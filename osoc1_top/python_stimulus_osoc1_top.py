import os
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

# =========================================================================
# IMPORT YOUR GOLDEN PYTHON MODEL
# =========================================================================
from osoc1_core_uarch import generate_hex_file, verify_cpu_results

@cocotb.test()
async def automated_system_regression_test(dut):
    """Executes dynamic firmware on osoc1_top and verifies final state."""
    
    # Grab the test name from the Makefile (defaults to 'logic_test')
    test_name = os.environ.get('TEST_NAME', 'logic_test')
    
    asm_file = f"{test_name}.asm"
    ref_file = f"{test_name}.expected.txt"
    hex_file = "firmware.hex"  # Must match SV $readmemh target
    dump_file = "hardware_actual_state.txt"
    
    dut._log.info(f"=== RUNNING REGRESSION SUITE: {test_name.upper()} ===")
    
    # =====================================================================
    # 0. ASSEMBLE CODE (Using your Golden Assembler)
    # =====================================================================
    total_instructions = generate_hex_file(asm_file, hex_file)
    if total_instructions == 0:
        dut._log.error("Assembler failed or file was empty. Halting simulation.")
        assert False, "Assembly Failure"
        
    dut._log.info(f"Compiled {total_instructions} instructions into {hex_file}")

    MAX_VAL = 0xFFFFFFFF
    MAX_CYCLES = 200

    ABI_NAMES = [
        'zero', 'ra', 'sp', 'gp', 'tp', 't0', 't1', 't2',
        's0/fp', 's1', 'a0', 'a1', 'a2', 'a3', 'a4', 'a5',
        'a6', 'a7', 's2', 's3', 's4', 's5', 's6', 's7',
        's8', 's9', 's10', 's11', 't3', 't4', 't5', 't6'
    ]

    # =====================================================================
    # 1. HARDWARE INITIALIZATION
    # =====================================================================
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())
    dut.rst_ni.value = 0
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    dut.rst_ni.value = 1

    # =====================================================================
    # 2. THE EXECUTION LOOP
    # =====================================================================
    # =====================================================================
    # 2. THE EXECUTION LOOP
    # =====================================================================
    halted = False
    for cycle in range(MAX_CYCLES):
        await RisingEdge(dut.clk_i)
        await Timer(1, unit="ns")
        
        # Safely attempt to read the hardware wires
        try:
            pc_curr = int(dut.u_cpu_core.pc_curr.value) & MAX_VAL
            instr_i = int(dut.u_cpu_core.instr_i.value) & MAX_VAL
        except ValueError:
            # If the CPU runs past the loaded firmware, it reads 'x' (uninitialized SRAM)
            dut._log.info("🛑 HALT: Uninitialized memory ('x') reached. End of program.")
            halted = True
            await RisingEdge(dut.clk_i) # One extra tick to finish write-back
            break
        
        # Halt on explicitly empty memory (0x00000000)
        if instr_i == 0x00000000:
            dut._log.info(f"🛑 HALT: Empty memory reached at PC 0x{pc_curr:08x}.")
            halted = True
            await RisingEdge(dut.clk_i) # One extra tick to finish write-back
            break
    # =====================================================================
    # 3. POST-MORTEM DUMP
    # =====================================================================
    dut._log.info("Extracting physical hardware state...")
    with open(dump_file, 'w') as f:
        f.write("--- Final Register State (ABI Mapping & Signed Check) ---\n")
        rf_handle = dut.u_cpu_core.u_reg_file.registers
        
        for i in range(32):
            try:
                # Safely attempt to read the register
                val_hex = int(rf_handle[i].value) & MAX_VAL
            except ValueError:
                # If the register was never written to, it contains 'x'
                # Your Python Golden Model initializes all registers to 0
                val_hex = 0

            val_dec = val_hex if val_hex < 0x80000000 else val_hex - 0x100000000
            
            # Formatted to perfectly match your expected.txt style
            f.write(f"x{i:02d} ({ABI_NAMES[i]:<6}) : 0x{val_hex:08x} ({val_dec:>12d})\n")


    # =====================================================================
    # 4. SPARSE REGRESSION VERIFICATION (Using your Golden Verifier)
    # =====================================================================
    dut._log.info("Running your Sparse Regression Check...")
    
    # This calls the exact function from your osoc1_core_uarch.py
    test_passed = verify_cpu_results(dump_file, ref_file)
    
    assert test_passed, "❗ ARCHITECTURE REGRESSION: Hardware state does not match Expected Reference."
    dut._log.info("🚀 ARCHITECTURE VERIFIED: Physical Silicon matches Golden Model.")
