#!/bin/bash
# Script 04
# Check if MAFFT and IQ3 is installed
#!/bin/bash

# List of programs to check and install
PROGRAMS=("mafft" "iqtree2")

# Function to check and install a program
install_program() {
    local program=$1
    
    echo "=================================================="
    echo "Checking $program..."
    echo "=================================================="
    
    # Check if program is already installed
    if command -v $program &> /dev/null; then
        echo "✓ $program is already installed."
        echo "  Location: $(which $program)"
        echo "  Version:  $($program --version 2>&1)"
        echo ""
        return 0
    fi
    
    echo "✗ $program is NOT installed. Attempting installation..."
    echo ""
    
    # Try conda installation first
    if command -v conda &> /dev/null; then
        echo "  → Conda detected. Installing $program via conda..."
        conda install -c bioconda $program -y
        if command -v $program &> /dev/null; then
            echo "  ✓ $program successfully installed via conda"
            $program --version
            echo ""
            return 0
        fi
    fi
    
    # Try apt (Debian/Ubuntu)
    if command -v apt &> /dev/null; then
        echo "  → apt detected. Installing $program via apt..."
        sudo apt update
        sudo apt install -y $program
        if command -v $program &> /dev/null; then
            echo "  ✓ $program successfully installed via apt"
            $program --version
            echo ""
            return 0
        fi
    fi
    
    # Try yum (RedHat/CentOS)
    if command -v yum &> /dev/null; then
        echo "  → yum detected. Installing $program via yum..."
        sudo yum install -y $program
        if command -v $program &> /dev/null; then
            echo "  ✓ $program successfully installed via yum"
            $program --version
            echo ""
            return 0
        fi
    fi
    
    # Try spack
    if command -v spack &> /dev/null; then
        echo "  → spack detected. Installing $program via spack..."
        spack install $program
        if command -v $program &> /dev/null; then
            echo "  ✓ $program successfully installed via spack"
            $program --version
            echo ""
            return 0
        fi
    fi
    
    # Try module system
    if command -v module &> /dev/null; then
        echo "  → Module system detected. Checking for available $program modules..."
        module avail $program 2>&1
        echo "  Try: module load $program"
        echo ""
        return 1
    fi
    
    # If all else fails
    echo "  ✗ Installation failed. $program could not be installed automatically."
    echo "  Please install manually or contact your system administrator."
    echo ""
    return 1
}

# Main script
echo ""
echo "=========================================="
echo "Bioinformatics Tools Installation Script"
echo "=========================================="
echo ""

# Check and install each program
for program in "${PROGRAMS[@]}"; do
    install_program "$program"
done

echo "=========================================="
echo "Installation process completed."
echo "=========================================="