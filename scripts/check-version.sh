#!/bin/bash

# Script to check for latest Recoll version from download page
# Following Zen of Python: Simple, explicit, readable
# Usage: ./check-version.sh [cask_file_path]

set -euo pipefail

# Source shared utilities
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "$SCRIPT_DIR/utils.sh"

# =============================================================================
# CONFIGURATION (Explicit is better than implicit)
# =============================================================================

readonly CASK_FILE="${1:-$DEFAULT_CASK_FILE}"

# =============================================================================
# MAIN FUNCTIONS (Simple is better than complex)
# =============================================================================

display_version_info() {
    local current_version="$1"
    local latest_version="$2"
    
    log_info "Current version: $current_version"
    log_info "Latest version:  $latest_version"
}

output_results() {
    local version="$1"
    local current_version="$2"
    local sha256="$3"
    local update_needed="$4"
    
    # Output for both GitHub Actions and local testing
    set_github_output "version" "$version"
    set_github_output "current_version" "$current_version"
    set_github_output "update_needed" "$update_needed"
    
    if [[ "$update_needed" == "true" ]]; then
        set_github_output "sha256" "$sha256"
    fi
}

check_for_update() {
    local current_version="$1"
    
    # Fetch download page content
    local download_page
    if ! download_page=$(fetch_webpage "$DOWNLOAD_URL"); then
        return 1
    fi
    
    # Extract versions
    local latest_version
    if ! latest_version=$(extract_latest_version "$download_page"); then
        return 1
    fi
    
    # Display version information
    display_version_info "$current_version" "$latest_version"
    
    # Check if update is needed
    if [[ "$latest_version" != "$current_version" ]]; then
        log_info "Update needed: $current_version -> $latest_version"
        
        # Fetch SHA256 for new version
        local sha256_hash
        if ! sha256_hash=$(fetch_sha256_hash "$latest_version"); then
            log_error "Failed to fetch SHA256 hash for version $latest_version"
            return 1
        fi
        
        output_results "$latest_version" "$current_version" "$sha256_hash" "true"
        log_success "Update information prepared successfully"
    else
        log_info "No update needed. Current version is up to date."
        output_results "$current_version" "$current_version" "" "false"
        log_success "Version check completed"
    fi
    
    return 0
}

# =============================================================================
# MAIN EXECUTION (Flat is better than nested)
# =============================================================================

main() {
    # Setup error handling
    setup_error_handling
    
    log_info "Starting Recoll version check..."
    
    # Validate inputs early (Flat is better than nested)
    validate_file_exists "$CASK_FILE" || exit 1
    
    # Extract current version
    local current_version
    if ! current_version=$(extract_current_version "$CASK_FILE"); then
        log_error "Failed to extract current version from $CASK_FILE"
        exit 1
    fi
    
    # Check for updates
    if ! check_for_update "$current_version"; then
        log_error "Version check failed"
        exit 1
    fi
    
    log_success "Version check completed successfully"
}

# Execute main function with all arguments
main "$@"

