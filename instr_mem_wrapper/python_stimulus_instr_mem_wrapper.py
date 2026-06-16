import random
import cocotb
from cocotb.triggers import Timer
from cocotb.clock import Clock

# Import your Golden Model
from osoc1_core_uarch import InstructionMemory 

@cocotb.test()
async def automated_instr_mem_wrapper_test(dut):
    """Verify Instruction Fetch wrapper, byte-to-word alignment, and limits."""
    
    # 1. Start the Background Clock (Required for the wrapper interface)
    cocotb.start_soon(Clock(dut.clk_i, 10, unit="ns").start())

    golden_imem = InstructionMemory()
    
    MAX_VAL = 0xFFFFFFFF
    MIN_VAL = 0x00000000
    
    # Read the depth parameter directly from the wrapper
    HW_DEPTH = int(dut.DEPTH.value)

    # =========================================================================
    # PHASE 1: DYNAMIC BACKDOOR MEMORY INITIALIZATION
    # =========================================================================
    dut._log.info("Backdoor loading instructions into hierarchical behavioral model...")
    
    # We must access the array THROUGH the wrapper hierarchy (u_behav_macro)
    mem_array_handle = dut.u_behav_macro.memory_array

    # 1. Load the Absolute Minimum Boundary instruction at Address 0
    min_instr = MIN_VAL
    golden_imem.load_instruction(0x00000000, min_instr)
    mem_array_handle[0].value = min_instr

    # 2. Load the Absolute Maximum Boundary instruction at Address 4
    max_instr = MAX_VAL
    golden_imem.load_instruction(0x00000004, max_instr)
    mem_array_handle[1].value = max_instr  # Hardware index 1 = PC 4

    # 3. Load standard instructions
    golden_imem.load_instruction(0x00000008, 0x00100093) # ADDI x1, x0, 1
    mem_array_handle[2].value = 0x00100093
    
    golden_imem.load_instruction(0x0000000C, 0x00208133) # ADD x2, x1, x2
    mem_array_handle[3].value = 0x00208133

    # =========================================================================
    # PHASE 2: TEST MATRIX EXECUTION
    # =========================================================================
    # Format: (Description, PC_Address)
    test_cases = [
        ("Absolute Min Boundary (Boot Addr)", MIN_VAL),
        ("Absolute Max Boundary Instruction", 0x00000004),
        ("Standard Fetch (PC=8)",             0x00000008),
        ("Standard Fetch (PC=12)",            0x0000000C),
        
        # --- Edge Cases & Hardware Protections ---
        ("Unaligned PC (Hardware ignores bottom bits)", 0x00000009), 
        ("Out-of-Bounds Max PC Boundary",               MAX_VAL), 
    ]

    # Add random fuzzing within valid depth
    for i in range(10):
        # Generate random byte-aligned valid PC
        random_word_idx = random.randint(4, HW_DEPTH - 1)
        rand_pc = random_word_idx * 4
        rand_instr = random.randint(MIN_VAL, MAX_VAL)
        
        # Load into both models
        golden_imem.load_instruction(rand_pc, rand_instr)
        mem_array_handle[random_word_idx].value = rand_instr
        
        test_cases.append((f"Random Valid Fetch {i}", rand_pc))

    dut._log.info("Starting Instruction Fetch Verification...")

    # Wait for initial clock edge alignment
    await Timer(1, unit="ns")

    for desc, pc in test_cases:
        
        # Drive the PC input wire on the wrapper
        dut.pc_i.value = pc
        
        # Combinational logic, just wait 1ns for propagation
        await Timer(1, unit="ns")

        # Read hardware and clamp to max boundary
        hw_instr = int(dut.instr_o.value) & MAX_VAL
        
        # Golden Model fetch
        # The Golden model expects exact addressing or returns 0. 
        # For the unaligned test to match hardware, we must align the PC in Python first
        aligned_pc = pc & 0xFFFFFFFC 
        exp_instr = golden_imem.read(aligned_pc)
        
        # Mimic the hardware out-of-bounds fallback
        if (aligned_pc // 4) >= HW_DEPTH:
            exp_instr = 0

        # Assert match
        assert hw_instr == exp_instr, \
            f"FAIL ({desc})! Exp: 0x{exp_instr:08X} | Act: 0x{hw_instr:08X} at PC: {pc}"
            
        dut._log.info(f"PASS: {desc} | PC: 0x{pc:08X} | Instr: 0x{hw_instr:08X}")

    dut._log.info("SUCCESS: Wrapped Instruction Memory perfectly byte-aligned and bounds checked!")
