#!/bin/bash

# Script to check for latest Recoll version from download page
# Usage: ./check-version.sh [cask_file_path]

set -e

CASK_FILE="${1:-Casks/recoll.rb}"
DOWNLOAD_URL="https://www.recoll.org/downloads/macos/"

echo "Checking for latest Recoll version..."

# Get current version from cask file
get_current_version() {
    if [ ! -f "$CASK_FILE" ]; then
        echo "Error: Cask file not found at $CASK_FILE" >&2
        exit 1
    fi
    
    local current_version
    current_version=$(grep "version '" "$CASK_FILE" | sed "s/.*version '\(.*\)'.*/\1/")
    echo "$current_version"
}

# Get latest version from download page
get_latest_version() {
    echo "Fetching download page..." >&2
    local download_page
    download_page=$(curl -s "$DOWNLOAD_URL")
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch download page" >&2
        exit 1
    fi
    
    # Extract the latest version from the HTML table
    # Look for the last DMG file in the table (most recent)
    local latest_version
    latest_version=$(echo "$download_page" | grep -o 'recoll-[0-9]\+\.[0-9]\+\.[0-9]\+-[0-9]\{8\}-[a-f0-9]\{8\}\.dmg' | tail -1 | sed 's/recoll-\(.*\)\.dmg/\1/')
    
    if [ -z "$latest_version" ]; then
        echo "Error: Could not extract latest version from download page" >&2
        exit 1
    fi
    
    echo "$latest_version"
}

# Get SHA256 hash for a specific version
get_sha256_hash() {
    local version="$1"
    local sha256_url="https://www.recoll.org/downloads/macos/recoll-${version}.dmg.sha256"
    
    echo "Fetching SHA256 hash from: $sha256_url" >&2
    local sha256_hash
    sha256_hash=$(curl -s "$sha256_url" | cut -d' ' -f1)
    
    if [ -z "$sha256_hash" ]; then
        echo "Error: Could not fetch SHA256 hash for version $version" >&2
        exit 1
    fi
    
    echo "$sha256_hash"
}

# Main execution
main() {
    local current_version
    local latest_version
    local sha256_hash
    
    current_version=$(get_current_version)
    latest_version=$(get_latest_version)
    
    echo "Current version: $current_version"
    echo "Latest version: $latest_version"
    
    if [ "$latest_version" != "$current_version" ]; then
        echo "Update needed: $current_version -> $latest_version"
        sha256_hash=$(get_sha256_hash "$latest_version")
        
        # Output for GitHub Actions (if GITHUB_OUTPUT exists) or local testing
        if [ -n "$GITHUB_OUTPUT" ]; then
            echo "version=$latest_version" >> "$GITHUB_OUTPUT"
            echo "current_version=$current_version" >> "$GITHUB_OUTPUT"
            echo "sha256=$sha256_hash" >> "$GITHUB_OUTPUT"
            echo "update_needed=true" >> "$GITHUB_OUTPUT"
        else
            echo "version=$latest_version"
            echo "current_version=$current_version"
            echo "sha256=$sha256_hash"
            echo "update_needed=true"
        fi
    else
        echo "No update needed. Current version is up to date."
        # Output for GitHub Actions (if GITHUB_OUTPUT exists) or local testing
        if [ -n "$GITHUB_OUTPUT" ]; then
            echo "version=$current_version" >> "$GITHUB_OUTPUT"
            echo "current_version=$current_version" >> "$GITHUB_OUTPUT"
            echo "update_needed=false" >> "$GITHUB_OUTPUT"
        else
            echo "version=$current_version"
            echo "current_version=$current_version"
            echo "update_needed=false"
        fi
    fi
}

main "$@"

