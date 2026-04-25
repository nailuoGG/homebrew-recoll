#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

readonly FORMULA_FILE="Formula/recoll-from-source.rb"
readonly FORMULA_DOWNLOAD_PAGE="https://www.recoll.org/pages/download.html"
readonly SOURCE_SHA256_TEMPLATE="https://www.recoll.org/recoll-%s.tar.gz.sha256"

fetch_latest_source_version() {
    log_info "Fetching latest source version from download page..."

    local page_content
    page_content=$(fetch_webpage "$FORMULA_DOWNLOAD_PAGE")

    local latest
    latest=$(grep -oE 'recoll-[0-9]+\.[0-9]+\.[0-9]+\.tar' <<< "$page_content" | head -1 | sed 's/recoll-\(.*\)\.tar/\1/')

    validate_not_empty "$latest" "Latest source version" || return 1

    echo "$latest"
}

fetch_source_sha256() {
    local version="$1"
    local sha256_url
    sha256_url=$(printf "$SOURCE_SHA256_TEMPLATE" "$version")

    log_info "Fetching SHA256 from: $sha256_url"

    local hash_content
    hash_content=$(fetch_webpage "$sha256_url")

    local sha256
    sha256=$(echo "$hash_content" | cut -d' ' -f1)

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
        sha256=$(fetch_source_sha256 "$latest_ver")

        set_github_output "formula_update_needed" "true"
        set_github_output "formula_version" "$latest_ver"
        set_github_output "formula_sha256" "$sha256"
    else
        log_info "Formula is up to date"
        set_github_output "formula_update_needed" "false"
    fi
}

main "$@"
