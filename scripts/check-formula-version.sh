#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"

readonly FORMULA_FILE="Formula/recoll.rb"
readonly FORMULA_DOWNLOAD_PAGE="https://www.recoll.org/pages/download.html"
readonly SOURCE_URL_TEMPLATE="https://www.recoll.org/recoll-%s.tar.gz"

fetch_latest_source_version() {
    log_info "Fetching latest source version from download page..."

    local page_content
    page_content=$(fetch_webpage "$FORMULA_DOWNLOAD_PAGE")

    local latest
    latest=$(echo "$page_content" | grep -oE 'recoll-[0-9]+\.[0-9]+\.[0-9]+\.tar' | head -1 | sed 's/recoll-\(.*\)\.tar/\1/')

    validate_not_empty "$latest" "Latest source version" || return 1

    echo "$latest"
}

calculate_source_sha256() {
    local version="$1"
    local source_url
    source_url=$(printf "$SOURCE_URL_TEMPLATE" "$version")

    log_info "Downloading source tarball to calculate SHA256: $source_url"

    local temp_file
    temp_file=$(mktemp)

    if ! curl -sLf -o "$temp_file" "$source_url"; then
        log_error "Failed to download: $source_url"
        rm -f "$temp_file"
        return 1
    fi

    local sha256
    sha256=$(shasum -a 256 "$temp_file" | cut -d' ' -f1)

    rm -f "$temp_file"

    validate_not_empty "$sha256" "Source SHA256" || return 1
    echo "$sha256"
}

main() {
    log_info "Checking Formula version..."

    local current_ver
    current_ver=$(extract_formula_version "$FORMULA_FILE")

    local latest_ver
    latest_ver=$(fetch_latest_source_version)

    log_info "Current Formula version: $current_ver"
    log_info "Latest source version: $latest_ver"

    if [[ "$latest_ver" != "$current_ver" ]]; then
        log_success "New version available: $latest_ver"

        local sha256
        sha256=$(calculate_source_sha256 "$latest_ver")

        set_github_output "formula_update_needed" "true"
        set_github_output "formula_version" "$latest_ver"
        set_github_output "formula_sha256" "$sha256"
    else
        log_info "Formula is up to date"
        set_github_output "formula_update_needed" "false"
    fi
}

main "$@"
