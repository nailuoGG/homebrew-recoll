#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

readonly FORMULA_FILE="Formula/recoll-from-source.rb"

update_formula() {
    local version="$1"
    local sha256="$2"

    validate_not_empty "$version" "Version" || return 1
    validate_not_empty "$sha256" "SHA256" || return 1
    validate_file_exists "$FORMULA_FILE" "Formula file" || return 1

    backup_file "$FORMULA_FILE"

    log_info "Updating Formula to version $version..."

    perl -pi -e "s|url \"https://www.recoll.org/recoll-.*\\.tar\\.gz\"|url \"https://www.recoll.org/recoll-${version}.tar.gz\"|" \
             -e "s|sha256 \".*\"|sha256 \"${sha256}\"|" "$FORMULA_FILE"

    local updated_ver
    updated_ver=$(extract_formula_version "$FORMULA_FILE")

    if [[ "$updated_ver" != "$version" ]]; then
        log_error "Version mismatch after update: expected $version, got $updated_ver"
        restore_backup "$FORMULA_FILE"
        return 1
    fi

    cleanup_backup "$FORMULA_FILE"
    log_success "Formula updated to version $version"
}

main() {
    local version="${1:?Usage: $0 VERSION SHA256}"
    local sha256="${2:?SHA256 required}"

    update_formula "$version" "$sha256"
}

main "$@"
