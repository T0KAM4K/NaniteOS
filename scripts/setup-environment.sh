#!/bin/bash
set -euo pipefail

# NaniteOS Development Environment Setup
# Auto-detects distribution and installs required toolchain

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Detect distribution
detect_distro() {
    if grep -q "WSL_DISTRO_NAME" /proc/version 2>/dev/null; then
        DISTRO="WSL"
        DISTRO_BASE=$(grep -oP "(?<=^ID=).+" /etc/os-release | tr -d '"')
    elif [ -f /etc/os-release ]; then
        DISTRO=$(grep -oP "(?<=^ID=).+" /etc/os-release | tr -d '"')
        DISTRO_BASE="$DISTRO"
    else
        print_error "Cannot detect Linux distribution"
        exit 1
    fi
    
    print_status "Detected distribution: $DISTRO (base: $DISTRO_BASE)"
}

# Install dependencies based on distro
install_deps() {
    case "$DISTRO_BASE" in
        debian|ubuntu)
            print_status "Installing dependencies for Debian/Ubuntu..."
            sudo apt-get update
            sudo apt-get install -y \
                build-essential \
                gcc \
                gcc-arm-none-eabi \
                gcc-multilib \
                g++ \
                g++-multilib \
                binutils \
                binutils-arm-none-eabi \
                nasm \
                yasm \
                qemu-system-x86 \
                qemu-system-arm \
                gdb \
                gdb-multiarch \
                git \
                make \
                cmake \
                pkg-config \
                libssl-dev \
                libelf-dev
            ;; 
        fedora)
            print_status "Installing dependencies for Fedora..."
            sudo dnf install -y \
                gcc \
                gcc-c++ \
                gcc-arm-linux-gnu \
                binutils \
                nasm \
                yasm \
                qemu-system-x86 \
                qemu-system-arm \
                gdb \
                gdb-gdbserver \
                git \
                make \
                cmake \
                pkgconfig \
                openssl-devel \
                elfutils-libelf-devel
            ;; 
        arch|manjaro)
            print_status "Installing dependencies for Arch/Manjaro..."
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                base-devel \
                gcc \
                arm-none-eabi-gcc \
                arm-none-eabi-binutils \
                nasm \
                yasm \
                qemu-full \
                gdb \
                arm-none-eabi-gdb \
                git \
                make \
                cmake \
                openssl \
                libelf
            ;; 
        *)
            print_error "Unsupported distribution: $DISTRO_BASE"
            print_warn "Please manually install the following tools:"
            echo "  - GCC (native and cross-compiler for ARM)"
            echo "  - NASM/YASM (assemblers)"
            echo "  - QEMU (x86, x86_64, ARM system emulators)"
            echo "  - GDB (debugger)"
            echo "  - GNU Make, CMake"
            exit 1
            ;; 
    esac
}

# Verify toolchain
verify_toolchain() {
    print_status "Verifying toolchain installation..."
    
    local missing=0
    
    for tool in gcc g++ nasm make cmake qemu-system-x86_64 gdb; do
        if ! command -v "$tool" &> /dev/null; then
            print_error "Missing: $tool"
            missing=$((missing + 1))
        else
            print_status "Found: $tool ($(command -v $tool))"
        fi
    done
    
    # Check for ARM cross-compiler
    if ! command -v arm-none-eabi-gcc &> /dev/null; then
        print_error "Missing: arm-none-eabi-gcc (ARM cross-compiler)"
        missing=$((missing + 1))
    else
        print_status "Found: arm-none-eabi-gcc"
    fi
    
    if [ $missing -gt 0 ]; then
        print_error "$missing tools are missing. Please install them manually."
        exit 1
    fi
    
    print_status "All required tools are installed!"
}

# Create build directories if they don't exist
setup_build_dirs() {
    print_status "Setting up build directories..."
    mkdir -p build/output/{x86,x86_64,arm}
    mkdir -p build/cache
    mkdir -p tests/qemu/images
    print_status "Build directories ready"
}

# Main
main() {
    echo "================================================"
    echo "  NaniteOS Development Environment Setup"
    echo "================================================"
    echo ""
    
detect_distro
    print_status "Installing required dependencies..."
    install_deps
    verify_toolchain
    setup_build_dirs
    
echo ""
    print_status "Setup complete! You're ready to build NaniteOS."
    echo ""
    echo "Next steps:"
    echo "  1. Review build configuration: cat build/config.mk"
    echo "  2. Build bootloaders: make -C build bootloaders"
    echo "  3. Build kernel: make -C build kernel"
    echo "  4. Create disk image: make -C build image"
    echo "  5. Test with QEMU: make -C build qemu-test"
}

main "$@"