#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test result tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    log_info "Running: $1"
}

# Determine tag file name based on environment
get_tag_filename() {
    if [ -n "$RIPPER_TAGS_EMACS" ]; then
        echo "TAGS"
    else
        echo "tags"
    fi
}

# Test 1: Build gem
test_build() {
    run_test "test_build"

    # Clean up old gems
    rm -f gem-ripper-tags*.gem

    # Build gem
    if gem build gem-ripper-tags.gemspec > /dev/null 2>&1; then
        if [ -f gem-ripper-tags-*.gem ]; then
            log_success "Gem built successfully"
            return 0
        else
            log_error "Gem file not found after build"
            return 1
        fi
    else
        log_error "Gem build failed"
        return 1
    fi
}

# Test 2: Install gem
test_install() {
    run_test "test_install"

    # Uninstall first (ignore errors)
    gem uninstall gem-ripper-tags -x -I 2>/dev/null || true

    # Install the built gem
    if gem install gem-ripper-tags-*.gem --local > /dev/null 2>&1; then
        # Verify it's installed
        if gem list gem-ripper-tags | grep -q "gem-ripper-tags"; then
            log_success "Gem installed successfully"
            return 0
        else
            log_error "Gem not found in gem list after install"
            return 1
        fi
    else
        log_error "Gem installation failed"
        return 1
    fi
}

# Test 3: Verify tags are generated for a specific gem
test_gem_has_tags() {
    local gem_name=$1
    local tag_file=$(get_tag_filename)

    # Find the gem's installation directory
    local gem_path=$(gem which "$gem_name" 2>/dev/null || echo "")

    if [ -z "$gem_path" ]; then
        log_error "Could not find gem: $gem_name"
        return 1
    fi

    local gem_dir=$(dirname "$(dirname "$gem_path")")
    local tags_path="$gem_dir/$tag_file"

    # Check if tags file exists
    if [ ! -f "$tags_path" ]; then
        log_error "$gem_name: $tag_file not found at $tags_path"
        return 1
    fi

    # Check if tags file is not empty (at least 100 bytes)
    local size=$(stat -f%z "$tags_path" 2>/dev/null || stat -c%s "$tags_path")
    if [ "$size" -lt 100 ]; then
        log_error "$gem_name: $tag_file is too small ($size bytes)"
        return 1
    fi

    # For Vim tags, verify format (tab-separated)
    if [ "$tag_file" = "tags" ]; then
        if ! grep -q $'\t' "$tags_path"; then
            log_error "$gem_name: Vim tags file doesn't contain tab-separated entries"
            return 1
        fi
    fi

    log_success "$gem_name: $tag_file exists and is valid ($size bytes)"
    return 0
}

# Test 4: Install popular gems and verify tags
test_popular_gems() {
    run_test "test_popular_gems"

    local all_passed=0

    # Install popular gems without documentation (faster)
    log_info "Installing test gems: rake, rspec, minitest..."
    gem install rake --no-document > /dev/null 2>&1
    gem install rspec --no-document > /dev/null 2>&1
    gem install minitest --no-document > /dev/null 2>&1

    # Test each gem
    test_gem_has_tags "rake" || all_passed=1
    test_gem_has_tags "rspec" || all_passed=1
    test_gem_has_tags "minitest" || all_passed=1

    return $all_passed
}

# Test 5: Manual reindex
test_reindex() {
    run_test "test_reindex"

    local tag_file=$(get_tag_filename)

    # Run reindex
    if [ -n "$RIPPER_TAGS_EMACS" ]; then
        gem ripper_tags --reindex --emacs > /dev/null 2>&1
    else
        gem ripper_tags --reindex > /dev/null 2>&1
    fi

    # Verify tags still exist for rake after reindex
    if test_gem_has_tags "rake"; then
        log_success "Reindex completed successfully"
        return 0
    else
        log_error "Tags missing or invalid after reindex"
        return 1
    fi
}

# Main test runner
main() {
    log_info "Starting gem-ripper-tags test suite"
    log_info "Ruby version: $(ruby --version)"
    log_info "RubyGems version: $(gem --version)"

    if [ -n "$RIPPER_TAGS_EMACS" ]; then
        log_info "Tag format: Emacs TAGS"
    else
        log_info "Tag format: Vim tags"
    fi

    # Run all tests
    test_build || exit 1
    test_install || exit 1
    test_popular_gems || exit 1
    test_reindex || exit 1

    # Summary
    echo ""
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo "Total tests: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    fi
}

# Run main if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
