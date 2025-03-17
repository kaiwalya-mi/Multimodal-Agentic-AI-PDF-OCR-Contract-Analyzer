#!/usr/bin/env python3
"""
ContractAI Analyzer - Main Entry Point

This script provides a simple entry point to run the ContractAI Analyzer.
It handles command-line arguments and delegates to the appropriate modules.
"""
import os
import sys
import argparse
import logging
import subprocess
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

def setup_environment():
    """Check if setup has been run and environment is ready"""
    if not os.path.exists(".venv"):
        logger.info("Virtual environment not found. Running setup script...")
        if os.name == 'nt':  # Windows
            subprocess.run(["bash", "scripts/setup.sh"], check=True)
        else:  # Unix/Linux/MacOS
            subprocess.run(["./scripts/setup.sh"], check=True)
    
    # Check if .env file exists
    if not os.path.exists(".env"):
        logger.info("Environment file not found. Creating from template...")
        subprocess.run(["cp", ".env.example", ".env"], check=True)
        logger.warning("Please edit the .env file to add your API keys.")

def run_analyzer(pdf_file, use_ocr=False, output_dir=None):
    """Run the contract analyzer on the specified PDF file"""
    # Validate PDF file
    pdf_path = Path(pdf_file)
    if not pdf_path.exists():
        logger.error(f"PDF file not found: {pdf_file}")
        return 1
    
    # If the file is in the examples directory, use the full path
    if not pdf_path.is_absolute() and not pdf_path.exists():
        examples_path = Path("examples") / pdf_path
        if examples_path.exists():
            pdf_path = examples_path
    
    # Set output directory
    if output_dir:
        output_path = Path(output_dir)
        if not output_path.exists():
            output_path.mkdir(parents=True, exist_ok=True)
    else:
        output_path = Path(".")
    
    # Import the analyzer module
    try:
        from src.contract_analyzer import ContractAnalyzer
        
        # Create analyzer
        analyzer = ContractAnalyzer()
        
        # Check if Mistral agent is available
        if not analyzer.mistral_agent:
            logger.error("Mistral agent not initialized. Check API key and dependencies.")
            return 1
        
        # Analyze contract
        logger.info(f"Analyzing contract: {pdf_path}")
        if use_ocr:
            logger.info("Using OCR for text extraction")
        
        results = analyzer.analyze_contract(str(pdf_path), use_ocr=use_ocr)
        
        if results:
            logger.info("Analysis completed successfully")
            
            # Save reports
            report_paths = analyzer.save_report(str(output_path))
            logger.info(f"Reports saved: {report_paths}")
            
            # Open HTML report if available
            if "html" in report_paths and os.path.exists(report_paths["html"]):
                try:
                    import webbrowser
                    webbrowser.open(f"file://{os.path.abspath(report_paths['html'])}")
                    logger.info(f"Opened HTML report in browser")
                except Exception as e:
                    logger.error(f"Could not open HTML report: {str(e)}")
            return 0
        else:
            logger.error("Analysis failed")
            return 1
    except ImportError:
        logger.error("Failed to import analyzer module. Make sure setup has been run.")
        return 1
    except Exception as e:
        logger.error(f"Error running analyzer: {str(e)}", exc_info=True)
        return 1

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description="ContractAI Analyzer - Analyze legal contracts in PDF format")
    parser.add_argument("pdf_file", help="Path to the PDF contract file to analyze")
    parser.add_argument("--ocr", action="store_true", help="Use OCR for text extraction (useful for scanned documents)")
    parser.add_argument("--output-dir", help="Directory to save the reports (defaults to current directory)")
    parser.add_argument("--setup", action="store_true", help="Run the setup script before analysis")
    
    args = parser.parse_args()
    
    # Run setup if requested or if environment is not ready
    if args.setup:
        setup_environment()
    
    # Run the analyzer
    return run_analyzer(args.pdf_file, use_ocr=args.ocr, output_dir=args.output_dir)

if __name__ == "__main__":
    sys.exit(main())