#!/bin/bash
# ContractAI Analyzer Setup Script
# This script sets up the environment for the ContractAI Analyzer

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up ContractAI Analyzer...${NC}"
echo -e "${YELLOW}This script will set up everything you need to run the ContractAI Analyzer.${NC}"

# Check if Python 3.9+ is installed
python_version=$(python3 --version 2>&1 | awk '{print $2}')
if [[ -z "$python_version" ]]; then
    echo -e "${RED}Python 3 not found. Please install Python 3.9 or higher.${NC}"
    exit 1
fi

major=$(echo $python_version | cut -d. -f1)
minor=$(echo $python_version | cut -d. -f2)

if [[ $major -lt 3 || ($major -eq 3 && $minor -lt 9) ]]; then
    echo -e "${RED}Python 3.9 or higher is required. Found Python $python_version${NC}"
    exit 1
fi

echo -e "${GREEN}Found Python $python_version${NC}"

# Check if virtual environment exists, create if not
if [[ ! -d ".venv" ]]; then
    echo -e "${YELLOW}Creating virtual environment...${NC}"
    python3 -m venv .venv
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to create virtual environment. Please install venv package.${NC}"
        exit 1
    fi
fi

# Activate virtual environment
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows
    source .venv/Scripts/activate
else
    # Unix/Linux/MacOS
    source .venv/bin/activate
fi

if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to activate virtual environment.${NC}"
    exit 1
fi

echo -e "${GREEN}Virtual environment activated.${NC}"

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
pip install --upgrade pip
pip install -r requirements.txt

if [[ $? -ne 0 ]]; then
    echo -e "${RED}Failed to install dependencies.${NC}"
    exit 1
fi

echo -e "${GREEN}Dependencies installed successfully.${NC}"

# Check if .env file exists, create from example if not
if [[ ! -f ".env" ]]; then
    echo -e "${YELLOW}Creating .env file from example...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}Please edit the .env file to add your API keys.${NC}"
fi

# Check for system dependencies
echo -e "${YELLOW}Checking system dependencies...${NC}"

# Check for Poppler (for PDF processing)
if command -v pdfinfo &> /dev/null; then
    echo -e "${GREEN}Poppler found.${NC}"
else
    echo -e "${RED}Poppler not found. PDF processing may not work correctly.${NC}"
    echo -e "${YELLOW}Please install Poppler:${NC}"
    echo -e "  - On macOS: brew install poppler"
    echo -e "  - On Ubuntu/Debian: apt-get install poppler-utils"
    echo -e "  - On Windows: Download from https://github.com/oschwartz10612/poppler-windows/releases/"
fi

# Check for Tesseract (for OCR)
if command -v tesseract &> /dev/null; then
    echo -e "${GREEN}Tesseract found.${NC}"
else
    echo -e "${RED}Tesseract not found. OCR functionality may not work correctly.${NC}"
    echo -e "${YELLOW}Please install Tesseract:${NC}"
    echo -e "  - On macOS: brew install tesseract"
    echo -e "  - On Ubuntu/Debian: apt-get install tesseract-ocr"
    echo -e "  - On Windows: Download from https://github.com/UB-Mannheim/tesseract/wiki"
fi

echo -e "${GREEN}Setup completed successfully!${NC}"
echo -e "${YELLOW}You can now run the ContractAI Analyzer:${NC}"
echo -e "  python analyze.py examples/sample_contract.pdf --ocr"
echo -e "${YELLOW}Or use the Makefile:${NC}"
echo -e "  make run"

# Deactivate virtual environment
deactivate