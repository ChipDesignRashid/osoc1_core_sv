import os
import sys
import ast

def get_golden_model_args(module_name):
    """Parses the Colab file to extract the exact input arguments of the function."""
    filepath = os.path.join("common", "osoc1_core_uarch.py")
    target_func = f"module_{module_name}"
    
    try:
        with open(filepath, "r") as f:
            tree = ast.parse(f.read())
            
        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef) and node.name == target_func:
                # Extract all argument names from the function signature
                return [arg.arg for arg in node.args.args]
                
    except FileNotFoundError:
        print(f"⚠️ Could not find {filepath}. Generating generic template.")
        
    return [] # Return empty if function isn't found

def create_scaffolding(module_name):
    # 1. Parse the Golden Model for exact port names
    args = get_golden_model_args(module_name)
    
    if not args:
        print(f"⚠️ Function 'module_{module_name}' not found in osoc1_core_uarch.py! Using generic ports.")
        args = ["in_a_i", "in_b_i"] # Fallback inputs

    # Auto-generate formatting based on the extracted arguments
    sv_inputs = "\n    ".join([f"input  logic [WIDTH-1:0] {arg}," for arg in args])
    py_args_csv = ", ".join(args)
    py_dut_drives = "\n        ".join([f"dut.{arg}.value = {arg}" for arg in args])
    
    # 2. Create the new folder
    if not os.path.exists(module_name):
        os.makedirs(module_name)
        print(f"✅ Created directory: {module_name}/")
    else:
        print(f"⚠️ Directory {module_name} already exists!")
        return

    # 3. Generate the Custom SystemVerilog Skeleton
    sv_code = f"""import cpu_sv_package::*;

module {module_name} #(
    parameter int WIDTH = 32
)(
    // Auto-Generated Inputs from Golden Model
    {sv_inputs}
    
    // TODO: Define your outputs (e.g., output logic [WIDTH-1:0] out_o)
    output logic [WIDTH-1:0] out_o
);

    // TODO: Write hardware logic here

endmodule
"""
    with open(f"{module_name}/{module_name}.sv", "w") as f:
        f.write(sv_code)
    print(f"✅ Created {module_name}.sv (with auto-populated ports!)")

    # 4. Generate the Makefile
    makefile_code = f"""SIM ?= icarus
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../common/cpu_sv_package.sv
VERILOG_SOURCES += $(PWD)/{module_name}.sv

TOPLEVEL = {module_name}
MODULE = python_stimulus_{module_name}

export PYTHONPATH := $(PWD)/../common:$(PYTHONPATH)
COMPILE_ARGS += -g2012
export COCOTB_HDL_TIMEUNIT = 1ns
export COCOTB_HDL_TIMEPRECISION = 1ps

include $(shell cocotb-config --makefiles)/Makefile.sim
"""
    with open(f"{module_name}/Makefile", "w") as f:
        f.write(makefile_code)
    print(f"✅ Created Makefile")

    # 5. Generate the Custom Cocotb Testbench
    py_code = f"""import random
import cocotb
from cocotb.triggers import Timer
from osoc1_core_uarch import module_{module_name}

# ==============================================================================
# AUTOMATED RANDOM VERIFICATION
# ==============================================================================
@cocotb.test()
async def automated_{module_name}_test(dut):
    \"\"\"Verify {module_name} using max/min boundaries and random inputs.\"\"\"
    
    MAX_VAL = 0xFFFFFFFF
    MIN_VAL = 0x00000000
    
    # Step A: Mandatory Maximum and Minimum Boundary Checks
    # Formatted for: ({py_args_csv})
    test_cases = [
        ({", ".join(["MAX_VAL"] * len(args))}), 
        ({", ".join(["MIN_VAL"] * len(args))})  
    ]
    
    # Step B: Constrained Random Vectors
    NUM_RANDOM_TESTS = 10 
    for _ in range(NUM_RANDOM_TESTS):
        test_cases.append(tuple(random.randint(MIN_VAL, MAX_VAL) for _ in range({len(args)})))

    dut._log.info("Starting {module_name} Verification...")
    dut._log.info("-" * 80)

    # Step C: The Execution Engine
    for {py_args_csv} in test_cases: 
        
        # 1. Auto-Generated Hardware Pin Driving
        {py_dut_drives}
        
        # 2. Wait for propagation
        await Timer(1, unit="ns")
        
        # 3. Ask Golden Oracle
        expected_results = module_{module_name}({py_args_csv})
        
        # 4. Read Hardware Pins (TODO: Update with your exact output pins)
        actual_results = int(dut.out_o.value)
        
        # 5. Log Output 
        dut._log.info(f"INPUTS: {{{py_args_csv}}} | EXP: {{expected_results}} | ACT: {{actual_results}}")
        
        # 6. Check Results (TODO: Adjust if Oracle returns a tuple of multiple outputs)
        assert actual_results == expected_results, f"FAIL! Expected: {{expected_results}} | Actual: {{actual_results}}"

    dut._log.info("-" * 80)
    dut._log.info("SUCCESS: Boundary and random tests passed for {module_name}!")
"""
    with open(f"{module_name}/python_stimulus_{module_name}.py", "w") as f:
        f.write(py_code)
    print(f"✅ Created python_stimulus_{module_name}.py (with auto-mapped stimulus!)")
    print(f"\n🚀 Scaffolding complete! Check the {module_name} folder.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python create_module.py <module_name>")
    else:
        create_scaffolding(sys.argv[1])
