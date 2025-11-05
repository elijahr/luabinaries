#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Test a Lua binary
test_lua_binary() {
    local binary=$1
    local expected_version=$2
    local platform=$3

    if [ ! -f "$binary" ]; then
        print_fail "Binary not found: $binary"
        return 1
    fi

    print_info "Testing: $binary"

    # Test 1: Binary is executable
    ((TESTS_RUN++))
    if [ -x "$binary" ]; then
        print_pass "Binary is executable"
    else
        print_fail "Binary is not executable"
        return 1
    fi

    # Test 2: Version check
    ((TESTS_RUN++))
    print_test "Checking Lua version"
    version_output=$("$binary" -v 2>&1 | head -n1 || true)
    if echo "$version_output" | grep -q "$expected_version"; then
        print_pass "Version check: $version_output"
    else
        print_fail "Version mismatch. Expected: $expected_version, Got: $version_output"
        return 1
    fi

    # Test 3: Execute simple Lua code
    ((TESTS_RUN++))
    print_test "Running simple Lua code"
    result=$("$binary" -e "print('hello')" 2>&1 || true)
    if [ "$result" = "hello" ]; then
        print_pass "Simple print statement works"
    else
        print_fail "Simple print failed. Output: $result"
        return 1
    fi

    # Test 4: Math operations
    ((TESTS_RUN++))
    print_test "Testing math operations"
    result=$("$binary" -e "print(2 + 2)" 2>&1 || true)
    if [ "$result" = "4" ]; then
        print_pass "Math operations work"
    else
        print_fail "Math operations failed. Expected: 4, Got: $result"
        return 1
    fi

    # Test 5: String operations
    ((TESTS_RUN++))
    print_test "Testing string operations"
    result=$("$binary" -e "print(string.upper('test'))" 2>&1 || true)
    if [ "$result" = "TEST" ]; then
        print_pass "String operations work"
    else
        print_fail "String operations failed. Expected: TEST, Got: $result"
        return 1
    fi

    # Test 6: Table operations
    ((TESTS_RUN++))
    print_test "Testing table operations"
    result=$("$binary" -e "t = {1, 2, 3}; print(#t)" 2>&1 || true)
    if [ "$result" = "3" ]; then
        print_pass "Table operations work"
    else
        print_fail "Table operations failed. Expected: 3, Got: $result"
        return 1
    fi

    # Test 7: Architecture verification (Linux/macOS only)
    if [ "$platform" != "windows" ] && command -v file &> /dev/null; then
        ((TESTS_RUN++))
        print_test "Verifying binary architecture"
        file_output=$(file "$binary")
        print_info "File info: $file_output"

        case "$platform" in
            linux-x64)
                if echo "$file_output" | grep -q "x86-64"; then
                    print_pass "Architecture verified: x86-64"
                else
                    print_fail "Expected x86-64 architecture"
                    return 1
                fi
                ;;
            linux-arm64)
                if echo "$file_output" | grep -q "ARM aarch64\|ARM 64"; then
                    print_pass "Architecture verified: ARM64"
                else
                    print_fail "Expected ARM64 architecture"
                    return 1
                fi
                ;;
            macos-x64)
                if echo "$file_output" | grep -q "x86_64"; then
                    print_pass "Architecture verified: x86_64"
                else
                    print_fail "Expected x86_64 architecture"
                    return 1
                fi
                ;;
            macos-arm64)
                if echo "$file_output" | grep -q "arm64"; then
                    print_pass "Architecture verified: arm64"
                else
                    print_fail "Expected arm64 architecture"
                    return 1
                fi
                ;;
        esac
    fi

    echo ""
    return 0
}

# Test luac compiler binary
test_luac_binary() {
    local luac_binary=$1
    local lua_binary=$2
    local expected_version=$3

    if [ ! -f "$luac_binary" ]; then
        print_fail "Luac binary not found: $luac_binary"
        return 1
    fi

    if [ ! -f "$lua_binary" ]; then
        print_fail "Lua binary not found (needed for luac test): $lua_binary"
        return 1
    fi

    print_info "Testing: $luac_binary"

    # Test 1: Binary is executable
    ((TESTS_RUN++))
    if [ -x "$luac_binary" ]; then
        print_pass "Luac binary is executable"
    else
        print_fail "Luac binary is not executable"
        return 1
    fi

    # Test 2: Compile and run Lua bytecode
    ((TESTS_RUN++))
    print_test "Compiling and running Lua bytecode"

    # Create temporary directory for test files
    temp_dir=$(mktemp -d)
    trap "rm -rf $temp_dir" EXIT

    # Create a simple Lua script
    echo "print('bytecode test')" > "$temp_dir/test.lua"

    # Compile it
    if "$luac_binary" -o "$temp_dir/test.luac" "$temp_dir/test.lua" 2>&1; then
        # Run the compiled bytecode
        result=$("$lua_binary" "$temp_dir/test.luac" 2>&1 || true)
        if [ "$result" = "bytecode test" ]; then
            print_pass "Bytecode compilation and execution works"
        else
            print_fail "Bytecode execution failed. Output: $result"
            return 1
        fi
    else
        print_fail "Bytecode compilation failed"
        return 1
    fi

    echo ""
    return 0
}

# Main test logic
main() {
    echo "========================================="
    echo "Lua Binaries Test Suite"
    echo "========================================="
    echo ""

    # Determine platform
    if [ -d "build/linux-x64" ]; then
        print_info "Testing Linux x64 binaries"
        for version in 51 53 54; do
            expected_ver=$(echo "$version" | sed 's/\(.\)\(.\)/\1.\2/')
            test_lua_binary "build/linux-x64/lua$version" "Lua $expected_ver" "linux-x64"
            test_luac_binary "build/linux-x64/luac$version" "build/linux-x64/lua$version" "Lua $expected_ver"
        done
    fi

    if [ -d "build/linux-arm64" ]; then
        print_info "Testing Linux ARM64 binaries"
        for version in 51 53 54; do
            expected_ver=$(echo "$version" | sed 's/\(.\)\(.\)/\1.\2/')
            test_lua_binary "build/linux-arm64/lua$version-linux-arm64" "Lua $expected_ver" "linux-arm64"
            test_luac_binary "build/linux-arm64/luac$version-linux-arm64" "build/linux-arm64/lua$version-linux-arm64" "Lua $expected_ver"
        done
    fi

    if [ -d "build/win64" ]; then
        print_info "Testing Windows x64 binaries"

        # Check if wine is available - it's required for Windows binary testing
        if ! command -v wine64 &> /dev/null; then
            print_fail "wine64 is required to test Windows binaries but is not installed"
            echo "Install wine64 with: sudo apt install wine64"
            exit 1
        fi

        for version in 51 53 54; do
            expected_ver=$(echo "$version" | sed 's/\(.\)\(.\)/\1.\2/')
            # Use wine to test Windows binaries
            test_lua_binary "build/win64/lua$version.exe" "Lua $expected_ver" "windows"
            test_luac_binary "build/win64/luac$version.exe" "build/win64/lua$version.exe" "Lua $expected_ver"
        done
    fi

    if [ -d "build/macos-x64" ]; then
        print_info "Testing macOS x64 binaries"
        for version in 51 53 54; do
            expected_ver=$(echo "$version" | sed 's/\(.\)\(.\)/\1.\2/')
            test_lua_binary "build/macos-x64/lua$version-macos-x64" "Lua $expected_ver" "macos-x64"
            test_luac_binary "build/macos-x64/luac$version-macos-x64" "build/macos-x64/lua$version-macos-x64" "Lua $expected_ver"
        done
    fi

    if [ -d "build/macos-arm64" ]; then
        print_info "Testing macOS ARM64 binaries"
        for version in 51 53 54; do
            expected_ver=$(echo "$version" | sed 's/\(.\)\(.\)/\1.\2/')
            test_lua_binary "build/macos-arm64/lua$version-macos-arm64" "Lua $expected_ver" "macos-arm64"
            test_luac_binary "build/macos-arm64/luac$version-macos-arm64" "build/macos-arm64/lua$version-macos-arm64" "Lua $expected_ver"
        done
    fi

    # Print summary
    echo "========================================="
    echo "Test Summary"
    echo "========================================="
    echo "Tests run: $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
}

main "$@"
