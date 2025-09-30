#!/bin/bash

# Script to update Recoll cask file with new version and SHA256
# Usage: ./update-cask.sh <version> <sha256> [cask_file_path]

set -e

VERSION="$1"
SHA256="$2"
CASK_FILE="${3:-Casks/recoll.rb}"

if [ -z "$VERSION" ] || [ -z "$SHA256" ]; then
    echo "Usage: $0 <version> <sha256> [cask_file_path]"
    exit 1
fi

if [ ! -f "$CASK_FILE" ]; then
    echo "Error: Cask file not found at $CASK_FILE"
    exit 1
fi

echo "Updating cask file: $CASK_FILE"
echo "Version: $VERSION"
echo "SHA256: $SHA256"

# Create backup
cp "$CASK_FILE" "${CASK_FILE}.backup"

# Update version
sed -i.tmp "s/version '[^']*'/version '$VERSION'/" "$CASK_FILE"

# Update sha256
sed -i.tmp "s/sha256 '[^']*'/sha256 '$SHA256'/" "$CASK_FILE"

# Clean up temporary files
rm -f "${CASK_FILE}.tmp"

echo "Cask file updated successfully:"
echo "---"
grep -E "(version|sha256)" "$CASK_FILE"
echo "---"

# Verify the update
verify_update() {
    local updated_version
    local updated_sha256
    
    updated_version=$(grep "version '" "$CASK_FILE" | sed "s/.*version '\(.*\)'.*/\1/")
    updated_sha256=$(grep "sha256 '" "$CASK_FILE" | sed "s/.*sha256 '\(.*\)'.*/\1/")
    
    if [ "$updated_version" != "$VERSION" ]; then
        echo "Error: Version update failed. Expected: $VERSION, Got: $updated_version"
        return 1
    fi
    
    if [ "$updated_sha256" != "$SHA256" ]; then
        echo "Error: SHA256 update failed. Expected: $SHA256, Got: $updated_sha256"
        return 1
    fi
    
    echo "Update verification successful"
    return 0
}

if ! verify_update; then
    echo "Restoring backup due to verification failure"
    mv "${CASK_FILE}.backup" "$CASK_FILE"
    exit 1
fi

# Remove backup on success
rm -f "${CASK_FILE}.backup"

