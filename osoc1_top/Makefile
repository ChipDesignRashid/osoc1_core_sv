# =========================================================================
# Cocotb Setup (CRITICAL ADDITIONS)
# =========================================================================
# Define the simulator and the language
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Define the root of the core modules (one directory up)
CORE_ROOT = ..

# Pass the TEST_NAME to Cocotb (defaults to logic_test if you just type 'make')
TEST_NAME ?= logic_test
export TEST_NAME

# =========================================================================
# 0. Packages (MUST BE COMPILED FIRST)
# =========================================================================
# Update this path to exactly where your package file lives!
VERILOG_SOURCES = $(CORE_ROOT)/common/cpu_sv_package.sv


# =========================================================================
# 1. Top Level & Core
# =========================================================================
# Use '=' on the first entry to cleanly initialize the list
VERILOG_SOURCES += $(PWD)/osoc1_top.sv
VERILOG_SOURCES += $(PWD)/osoc1_cpu_core.sv

# =========================================================================
# 2. Execution Modules
# =========================================================================
VERILOG_SOURCES += $(CORE_ROOT)/pc_reg/pc_reg.sv
VERILOG_SOURCES += $(CORE_ROOT)/pc_plus_4/pc_plus_4.sv
VERILOG_SOURCES += $(CORE_ROOT)/decoder/decoder.sv
VERILOG_SOURCES += $(CORE_ROOT)/ctrl/ctrl.sv
VERILOG_SOURCES += $(CORE_ROOT)/reg_file/reg_file.sv
VERILOG_SOURCES += $(CORE_ROOT)/alu_in_muxes/alu_in_muxes.sv
VERILOG_SOURCES += $(CORE_ROOT)/alu/alu.sv
VERILOG_SOURCES += $(CORE_ROOT)/sau/sau.sv
VERILOG_SOURCES += $(CORE_ROOT)/lau/lau.sv
VERILOG_SOURCES += $(CORE_ROOT)/rf_wb_mux/rf_wb_mux.sv
VERILOG_SOURCES += $(CORE_ROOT)/bcu/bcu.sv
VERILOG_SOURCES += $(CORE_ROOT)/next_pc_logic/next_pc_logic.sv
# (Add imm_gen here when created)

# =========================================================================
# 3. Memories
# =========================================================================
VERILOG_SOURCES += $(CORE_ROOT)/instr_mem_wrapper/instr_mem_wrapper.sv
VERILOG_SOURCES += $(CORE_ROOT)/instr_mem_wrapper/instr_mem_behavioral.sv
VERILOG_SOURCES += $(CORE_ROOT)/data_mem_wrapper/data_mem_wrapper.sv
VERILOG_SOURCES += $(CORE_ROOT)/data_mem_wrapper/data_mem_behavioral.sv

# =========================================================================
# Cocotb Testbench Targeting
# =========================================================================
TOPLEVEL = osoc1_top
MODULE   = python_stimulus_osoc1_top

# =========================================================================
# Compiler Arguments & Environment
# =========================================================================
export PYTHONPATH := $(PWD)/../common:$(PYTHONPATH)
COMPILE_ARGS += -g2012
export COCOTB_HDL_TIMEUNIT = 1ns
export COCOTB_HDL_TIMEPRECISION = 1ps

include $(shell cocotb-config --makefiles)/Makefile.sim
