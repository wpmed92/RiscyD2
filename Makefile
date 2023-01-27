TB_CHECKER=python3 chip/tb/test_bench_checker.py
IV_C=iverilog
IV_RUN=vvp

CHIP_DIR=./chip
RTL_DIR=$(CHIP_DIR)/rtl
TB_DIR=$(CHIP_DIR)/tb

.PHONY: test

test: tb_alu.tbout tb_uart.tbout tb_multiplier.tbout

tb_uart.bin: $(TB_DIR)/tb_uart.v $(RTL_DIR)/uart_rx.v $(RTL_DIR)/uart_tx.v
	$(IV_C) -o $(TB_DIR)/$@ $^
	$(IV_RUN) $(TB_DIR)/$@
	
tb_alu.bin: $(TB_DIR)/tb_alu.v $(RTL_DIR)/alu.v
	$(IV_C) -o $(TB_DIR)/$@ -I $(RTL_DIR) $^ 
	$(IV_RUN) $(TB_DIR)/$@

tb_multiplier.bin: $(TB_DIR)/tb_multiplier.v $(RTL_DIR)/multiplier.v
	$(IV_C) -o $(TB_DIR)/$@ -I $(RTL_DIR) $^ 
	$(IV_RUN) $(TB_DIR)/$@

%.tbout: %.bin
	@test "$(shell $(TB_CHECKER) -i $@)" = "$(shell echo "PASSED")" \
		|| { echo Testbench failed $(shell $(TB_CHECKER) -i $@); exit 2; } \
		&& { echo $@: test succesful; }
