#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Setup QEMU for multi-arch support (if not already set up)
setup_qemu() {
    print_info "Setting up QEMU for multi-architecture support"

    # Check if docker buildx is available
    if ! docker buildx version &> /dev/null; then
        print_error "docker buildx is not available. Please update Docker to a version that supports buildx."
        exit 1
    fi

    # Setup binfmt_misc for QEMU (allows running ARM binaries on x64)
    if ! docker run --privileged --rm tonistiigi/binfmt --install all &> /dev/null; then
        print_info "QEMU binfmt already configured or configuration not needed"
    else
        print_success "QEMU binfmt configured successfully"
    fi
}

# Test Linux x64 binaries in a minimal container
test_linux_x64() {
    print_info "Testing Linux x64 binaries in Docker (amd64)"

    if [ ! -d "build/linux-x64" ]; then
        print_error "build/linux-x64 directory not found"
        return 1
    fi

    docker run --rm --platform linux/amd64 \
        -v "$(pwd)/build/linux-x64:/binaries:ro" \
        alpine:latest \
        sh -c '
            echo "Testing in $(uname -m) container"
            for version in 51 53 54; do
                echo "----------------------------------------"
                echo "Testing lua$version"
                /binaries/lua$version -v
                /binaries/lua$version -e "print(\"Hello from Lua $version\")"
                /binaries/lua$version -e "print(2 + 2)"
                echo "Testing luac$version"
                /binaries/luac$version -v
                echo "----------------------------------------"
            done
        '

    if [ $? -eq 0 ]; then
        print_success "Linux x64 tests passed"
        return 0
    else
        print_error "Linux x64 tests failed"
        return 1
    fi
}

# Test Linux ARM64 binaries in an ARM64 container (using QEMU emulation on x64 hosts)
test_linux_arm64() {
    print_info "Testing Linux ARM64 binaries in Docker (arm64/v8)"

    if [ ! -d "build/linux-arm64" ]; then
        print_error "build/linux-arm64 directory not found"
        return 1
    fi

    # This will use QEMU to emulate ARM64 on x64 hosts
    docker run --rm --platform linux/arm64/v8 \
        -v "$(pwd)/build/linux-arm64:/binaries:ro" \
        alpine:latest \
        sh -c '
            echo "Testing in $(uname -m) container"
            for version in 51 53 54; do
                echo "----------------------------------------"
                echo "Testing lua$version-linux-arm64"
                /binaries/lua$version-linux-arm64 -v
                /binaries/lua$version-linux-arm64 -e "print(\"Hello from Lua $version on ARM64\")"
                /binaries/lua$version-linux-arm64 -e "print(2 + 2)"
                echo "Testing luac$version-linux-arm64"
                /binaries/luac$version-linux-arm64 -v
                echo "----------------------------------------"
            done
        '

    if [ $? -eq 0 ]; then
        print_success "Linux ARM64 tests passed"
        return 0
    else
        print_error "Linux ARM64 tests failed"
        return 1
    fi
}

# Verify architecture of binaries
verify_architectures() {
    print_info "Verifying binary architectures"

    docker run --rm --platform linux/amd64 \
        -v "$(pwd)/build:/binaries:ro" \
        alpine:latest \
        sh -c '
            apk add --no-cache file > /dev/null 2>&1

            echo "=== Linux x64 binaries ==="
            if [ -d "/binaries/linux-x64" ]; then
                for f in /binaries/linux-x64/lua*; do
                    [ -f "$f" ] && file "$f" | grep -q "x86-64" && echo "✓ $(basename $f): x86-64" || echo "✗ $(basename $f): NOT x86-64"
                done
            fi

            echo ""
            echo "=== Linux ARM64 binaries ==="
            if [ -d "/binaries/linux-arm64" ]; then
                for f in /binaries/linux-arm64/lua*; do
                    [ -f "$f" ] && file "$f" | grep -q "aarch64" && echo "✓ $(basename $f): ARM64" || echo "✗ $(basename $f): NOT ARM64"
                done
            fi
        '
}

# Test 32-bit execution capability (if we add 32-bit builds in the future)
test_32bit_on_64bit() {
    print_info "Testing 32-bit binary execution on 64-bit system"

    # This is for future use if 32-bit binaries are added
    print_info "32-bit builds not currently implemented, skipping"
}

# Main test logic
main() {
    echo "========================================="
    echo "Docker-based Multi-Architecture Test Suite"
    echo "========================================="
    echo ""

    local failed=0

    # Setup QEMU
    setup_qemu
    echo ""

    # Verify architectures
    verify_architectures
    echo ""

    # Test Linux x64
    if test_linux_x64; then
        echo ""
    else
        ((failed++))
    fi

    # Test Linux ARM64 (will use QEMU emulation on x64 hosts)
    if test_linux_arm64; then
        echo ""
    else
        ((failed++))
    fi

    # Summary
    echo "========================================="
    echo "Docker Test Summary"
    echo "========================================="

    if [ $failed -eq 0 ]; then
        print_success "All Docker tests passed!"
        exit 0
    else
        print_error "$failed test suite(s) failed"
        exit 1
    fi
}

main "$@"
