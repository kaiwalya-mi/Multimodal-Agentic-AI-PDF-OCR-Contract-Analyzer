# ContractAI Analyzer Makefile

help:
	@echo "ContractAI Analyzer - Makefile Commands"
	@echo "-----------------------------------"
	@echo "setup     - Set up the environment"
	@echo "run       - Run the analyzer on the example contract"
	@echo "analyze   - Analyze a specific contract (PDF=path/to/contract.pdf, OCR=true/false)"
	@echo "clean     - Remove generated files"
	@echo "help      - Show this help message"

.PHONY: setup run analyze clean help

setup:
	@echo "Setting up ContractAI Analyzer..."
	@chmod +x scripts/setup.sh
	@./scripts/setup.sh

run:
	@echo "Running ContractAI Analyzer on example contract..."
	@python analyze.py examples/DigitalCinemaDestinationsCorp_20111220_S-1_EX-10.10_7346719_EX-10.10_Affiliate\ Agreement.pdf --ocr

analyze:
	@if [ -z "$(PDF)" ]; then \
		echo "Error: Please specify a PDF file with PDF=path/to/contract.pdf"; \
		exit 1; \
	fi
	@if [ "$(OCR)" = "true" ]; then \
		python analyze.py "$(PDF)" --ocr; \
	else \
		python analyze.py "$(PDF)"; \
	fi

clean:
	@echo "Cleaning up generated files..."
	@rm -f contract_analysis.md contract_analysis_report.html contract_analysis.pdf
	@echo "Done."