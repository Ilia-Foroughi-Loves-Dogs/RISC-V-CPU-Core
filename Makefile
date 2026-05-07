.PHONY: help clean test

help:
	@echo "RISC-V CPU Core"
	@echo ""
	@echo "Available targets:"
	@echo "  make help    Show this help message"
	@echo "  make test    Run project tests"
	@echo "  make clean   Remove generated simulation and build outputs"

test:
	@echo "Tests are not implemented yet."

clean:
	@echo "Cleaning generated files..."
	@rm -rf build sim/build obj_dir xsim.dir work
	@rm -f *.vcd *.fst *.ghw *.wdb *.jou *.log *.pb *.o *.out
