#!/bin/bash

# Script to update Recoll cask file with new version and SHA256
# Following Zen of Python: Explicit, simple, readable
# Usage: ./update-cask.sh <version> <sha256> [cask_file_path]

set -euo pipefail

# Source shared utilities
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "$SCRIPT_DIR/utils.sh"

# =============================================================================
# CONFIGURATION (Explicit is better than implicit)
# =============================================================================

readonly VERSION="$1"
readonly SHA256="$2"
readonly CASK_FILE="${3:-$DEFAULT_CASK_FILE}"

# =============================================================================
# VALIDATION (Errors should never pass silently)
# =============================================================================

validate_inputs() {
    validate_not_empty "$VERSION" "Version" || return 1
    validate_not_empty "$SHA256" "SHA256" || return 1
    validate_file_exists "$CASK_FILE" "Cask file" || return 1
    return 0
}

display_update_info() {
    log_info "Updating cask file: $CASK_FILE"
    log_info "Version: $VERSION"
    log_info "SHA256: $SHA256"
}

# =============================================================================
# UPDATE FUNCTIONS (Simple is better than complex)
# =============================================================================

update_cask_field() {
    local field="$1"
    local value="$2"
    
    # Use more explicit sed command with clear pattern matching
    sed -i.tmp "s/${field} '[^']*'/${field} '${value}'/" "$CASK_FILE"
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to update $field field"
        return 1
    fi
    
    return 0
}

perform_cask_updates() {
    log_info "Performing cask file updates..."
    
    # Update version field
    if ! update_cask_field "version" "$VERSION"; then
        return 1
    fi
    
    # Update sha256 field
    if ! update_cask_field "sha256" "$SHA256"; then
        return 1
    fi
    
    # Clean up temporary files
    rm -f "${CASK_FILE}.tmp"
    
    log_success "Cask file updates completed"
    return 0
}

# =============================================================================
# VERIFICATION (Readability counts)
# =============================================================================

display_updated_fields() {
    log_info "Updated cask file content:"
    grep -E "(version|sha256)" "$CASK_FILE" | sed 's/^/  /'
}

verify_field_update() {
    local field="$1"
    local expected_value="$2"
    
    local actual_value
    actual_value=$(grep "${field} '" "$CASK_FILE" | sed "s/.*${field} '\(.*\)'.*/\1/")
    
    if [[ "$actual_value" != "$expected_value" ]]; then
        log_error "${field} update verification failed"
        log_error "Expected: $expected_value"
        log_error "Actual:   $actual_value"
        return 1
    fi
    
    return 0
}

verify_cask_updates() {
    log_info "Verifying cask file updates..."
    
    # Verify version update
    if ! verify_field_update "version" "$VERSION"; then
        return 1
    fi
    
    # Verify SHA256 update
    if ! verify_field_update "sha256" "$SHA256"; then
        return 1
    fi
    
    log_success "All updates verified successfully"
    return 0
}

# =============================================================================
# CLEANUP HANDLING (Practicality beats purity)
# =============================================================================

cleanup_on_failure() {
    log_info "Update verification failed, restoring backup..."
    restore_backup "$CASK_FILE"
}

# Override cleanup function from utils.sh
cleanup_on_exit() {
    cleanup_backup "$CASK_FILE"
}

# =============================================================================
# MAIN EXECUTION (Flat is better than nested)
# =============================================================================

main() {
    # Setup error handling
    setup_error_handling
    
    log_info "Starting Recoll cask update..."
    
    # Validate inputs early
    validate_inputs || exit 1
    
    # Display update information
    display_update_info
    
    # Create backup before making changes
    backup_file "$CASK_FILE"
    
    # Perform the updates
    if ! perform_cask_updates; then
        cleanup_on_failure
        exit 1
    fi
    
    # Display updated content
    display_updated_fields
    
    # Verify the updates
    if ! verify_cask_updates; then
        cleanup_on_failure
        exit 1
    fi
    
    # Cleanup will be handled automatically by cleanup_on_exit
    log_success "Cask file updated successfully"
}

# Show usage if insufficient arguments
if [[ $# -lt 2 ]]; then
    log_error "Insufficient arguments provided"
    log_error "Usage: $0 <version> <sha256> [cask_file_path]"
    exit 1
fi

# Execute main function with all arguments
main "$@"

