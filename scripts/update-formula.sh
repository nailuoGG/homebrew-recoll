#!/bin/bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"

readonly FORMULA_FILE="Formula/recoll.rb"

update_formula() {
    local version="$1"
    local sha256="$2"

    validate_not_empty "$version" "Version" || return 1
    validate_not_empty "$sha256" "SHA256" || return 1
    validate_file_exists "$FORMULA_FILE" "Formula file" || return 1

    backup_file "$FORMULA_FILE"

    log_info "Updating Formula to version $version..."

    sed -i.bak "s|url \"https://www.recoll.org/recoll-.*\.tar\.gz\"|url \"https://www.recoll.org/recoll-${version}.tar.gz\"|" "$FORMULA_FILE"
    sed -i.bak "s|sha256 \".*\"|sha256 \"${sha256}\"|" "$FORMULA_FILE"
    rm -f "${FORMULA_FILE}.bak"

    local updated_sha
    updated_sha=$(grep 'sha256 "' "$FORMULA_FILE" | grep -oE '[a-f0-9]{64}')

    if [[ "$updated_sha" != "$sha256" ]]; then
        log_error "SHA256 mismatch after update: expected $sha256, got $updated_sha"
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
