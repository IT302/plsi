# Copyright 2016 Palmer Dabbelt <palmer@dabbelt.com>

# This contains a Black Box definition for the top level of the simulator.
$(OBJ_SOC_DIR)/generated-src/$(SOC_SIM_TOP).bb.json:
	@mkdir -p $(dir $@)
	echo "[ { \"name\": \"$(SOC_SIM_TOP)\" } ]" > $@

# All the simulation files should continue to be black boxed when producing
# other things -- since these can be super flaky I don't want to fight with
# hand written Verilog.
$(OBJ_SOC_DIR)/generated-src/$(SOC_SIM_TOP).sim_files.bb.json: \
		$(CMD_PCAD_GENERATE_BB) \
		$(OBJ_CORE_SIM_FILES) \
		$(OBJ_SOC_DIR)/generated-rc/$(SOC_SIM_TOP).bb.json
	mkdir -p $(dir $@)
	$(CMD_PCAD_GENERATE_BB) $(patsubst %,-i %,$(filter %.vh,$^)) $(patsubst %,-i %,$(filter %.v,$^)) $(patsubst %,-i %,$(filter %.bb.json,$^)) -o $@

# Here we split Rocket Chip's Chisel generated Verilog into two parts: one that
# contains only the chip's top-level code, and another that has all the test
# code.
$(OBJ_SOC_RTL_V): $(CMD_PCAD_TO_VERILOG) $(OBJ_CORE_RTL_V) $(OBJ_SOC_DIR)/generated-src/$(SOC_SIM_TOP).sim_files.bb.json
	mkdir -p $(dir $@)
	$(CMD_PCAD_TO_VERILOG) $(patsubst %,-i %,$(filter %.vh,$^)) $(patsubst %,-i %,$(filter %.v,$^)) -o $@ --top $(SOC_TOP)
