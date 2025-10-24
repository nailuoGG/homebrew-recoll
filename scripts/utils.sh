#!/bin/bash

# Shared utility functions for Recoll Homebrew scripts
# Following Zen of Python principles: Explicit, simple, readable

set -euo pipefail

# =============================================================================
# CONSTANTS (Explicit is better than implicit)
# =============================================================================

readonly DOWNLOAD_URL="https://www.recoll.org/downloads/macos/"
readonly VERSION_PATTERN='recoll-[0-9]\+\.[0-9]\+\.[0-9]\+-[0-9]\{8\}-[a-f0-9]\{8\}\.dmg'
readonly DEFAULT_CASK_FILE="Casks/recoll.rb"
readonly GITHUB_OUTPUT_FILE="${GITHUB_OUTPUT:-}"

# =============================================================================
# LOGGING FUNCTIONS (Readability counts)
# =============================================================================

log_info() {
    echo "[INFO] $*" >&2
}

log_error() {
    echo "[ERROR] $*" >&2
}

log_success() {
    echo "[SUCCESS] $*" >&2
}

# =============================================================================
# VALIDATION FUNCTIONS (Errors should never pass silently)
# =============================================================================

validate_file_exists() {
    local file_path="$1"
    local description="${2:-File}"
    
    if [[ ! -f "$file_path" ]]; then
        log_error "$description not found at: $file_path"
        return 1
    fi
    return 0
}

validate_not_empty() {
    local value="$1"
    local description="${2:-Value}"
    
    if [[ -z "$value" ]]; then
        log_error "$description cannot be empty"
        return 1
    fi
    return 0
}

validate_url_accessible() {
    local url="$1"
    
    if ! curl --output /dev/null --silent --head --fail "$url"; then
        log_error "URL not accessible: $url"
        return 1
    fi
    return 0
}

# =============================================================================
# NETWORK FUNCTIONS (Simple is better than complex)
# =============================================================================

fetch_webpage() {
    local url="$1"
    
    log_info "Fetching: $url"
    
    if ! validate_url_accessible "$url"; then
        return 1
    fi
    
    local content
    if ! content=$(curl -s --fail "$url"); then
        log_error "Failed to fetch content from: $url"
        return 1
    fi
    
    echo "$content"
}

fetch_sha256_hash() {
    local version="$1"
    local sha256_url="${DOWNLOAD_URL}recoll-${version}.dmg.sha256"
    
    log_info "Fetching SHA256 hash for version: $version"
    
    local hash_content
    if ! hash_content=$(fetch_webpage "$sha256_url"); then
        return 1
    fi
    
    # Extract hash (first field of SHA256 file)
    local sha256_hash
    sha256_hash=$(echo "$hash_content" | cut -d' ' -f1)
    
    if ! validate_not_empty "$sha256_hash" "SHA256 hash"; then
        return 1
    fi
    
    echo "$sha256_hash"
}

# =============================================================================
# FILE OPERATIONS (Explicit is better than implicit)
# =============================================================================

backup_file() {
    local file_path="$1"
    local backup_path="${file_path}.backup"
    
    if [[ -f "$file_path" ]]; then
        log_info "Creating backup: $backup_path"
        cp "$file_path" "$backup_path"
    fi
}

restore_backup() {
    local file_path="$1"
    local backup_path="${file_path}.backup"
    
    if [[ -f "$backup_path" ]]; then
        log_info "Restoring backup: $backup_path"
        mv "$backup_path" "$file_path"
    fi
}

cleanup_backup() {
    local file_path="$1"
    local backup_path="${file_path}.backup"
    
    if [[ -f "$backup_path" ]]; then
        log_info "Cleaning up backup: $backup_path"
        rm -f "$backup_path"
    fi
}

# =============================================================================
# GITHUB OUTPUT UTILITIES (Practicality beats purity)
# =============================================================================

set_github_output() {
    local key="$1"
    local value="$2"
    
    if [[ -n "$GITHUB_OUTPUT_FILE" ]]; then
        echo "${key}=${value}" >> "$GITHUB_OUTPUT_FILE"
    else
        echo "${key}=${value}"
    fi
}

# =============================================================================
# VERSION EXTRACTION (Flat is better than nested)
# =============================================================================

extract_current_version() {
    local cask_file="$1"
    
    validate_file_exists "$cask_file" "Cask file" || return 1
    
    local version
    version=$(grep "version '" "$cask_file" | sed "s/.*version '\(.*\)'.*/\1/")
    
    validate_not_empty "$version" "Current version" || return 1
    
    echo "$version"
}

extract_latest_version() {
    local download_page="$1"
    
    validate_not_empty "$download_page" "Download page content" || return 1
    
    # Extract the latest version from the HTML table (most recent DMG file)
    local latest_version
    latest_version=$(echo "$download_page" | grep -o "$VERSION_PATTERN" | tail -1 | sed "s/recoll-\(.*\)\.dmg/\1/")
    
    validate_not_empty "$latest_version" "Latest version" || return 1
    
    echo "$latest_version"
}

# =============================================================================
# EXIT HANDLING (Errors should never pass silently)
# =============================================================================

setup_error_handling() {
    set -euo pipefail
    
    # Trap errors and cleanup
    trap 'handle_error $? $LINENO' ERR
    trap 'cleanup_on_exit' EXIT
}

handle_error() {
    local exit_code="$1"
    local line_number="$2"
    
    log_error "Script failed with exit code $exit_code at line $line_number"
    exit "$exit_code"
}

cleanup_on_exit() {
    # Override in individual scripts for specific cleanup
    return 0
}

# Initialize error handling if this script is sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    setup_error_handling
fi