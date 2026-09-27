#!/usr/bin/env bash
# Release script for Blink Arcana
# Usage: ./scripts/release.sh <version> [--dry-run]
# Example: ./scripts/release.sh 0.1.0
#          ./scripts/release.sh 0.1.0 --dry-run

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

VERSION="${1:-}"
DRY_RUN="${2:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Validate version format (semver)
validate_version() {
    if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$ ]]; then
        log_error "Invalid version format. Use semantic versioning (e.g., 0.1.0, 1.0.0-beta.1)"
        exit 1
    fi
}

# Check if working directory is clean
check_clean() {
    if [[ -n "$(git status --porcelain)" ]]; then
        log_error "Working directory is not clean. Commit or stash changes first."
        git status --short
        exit 1
    fi
}

# Check if on main branch
check_branch() {
    local branch
    branch=$(git branch --show-current)
    if [[ "$branch" != "main" && "$branch" != "master" ]]; then
        log_warn "Not on main/master branch (current: $branch). Continue anyway? (y/N)"
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Run CI checks
run_ci_checks() {
    log_info "Running CI checks..."
    if [[ "$DRY_RUN" != "--dry-run" ]]; then
        just ci-check
    else
        log_warn "DRY RUN: Skipping CI checks"
    fi
}

# Update version in files
update_versions() {
    log_info "Updating version to $VERSION..."

    # Cargo.toml files
    find rust -name "Cargo.toml" -exec sed -i "s/^version = \".*\"/version = \"$VERSION\"/" {} \;

    # Justfile
    # No version in justfile currently

    # README.md (if has version badge)
    # sed -i "s/version-[0-9.]\+/version-$VERSION/" README.md 2>/dev/null || true

    log_success "Version updated in Cargo.toml files"
}

# Generate changelog
generate_changelog() {
    log_info "Generating changelog..."

    local prev_tag
    prev_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

    if [[ -n "$prev_tag" ]]; then
        log_info "Previous tag: $prev_tag"
        git log --pretty=format:"- %s (%h)" "$prev_tag"..HEAD > CHANGELOG_TMP.md
    else
        log_info "No previous tag, generating from start"
        git log --pretty=format:"- %s (%h)" > CHANGELOG_TMP.md
    fi

    # Prepend to CHANGELOG.md
    {
        echo "# Changelog"
        echo ""
        echo "## [$VERSION] - $(date +%Y-%m-%d)"
        echo ""
        cat CHANGELOG_TMP.md
        echo ""
        echo ""
        cat CHANGELOG.md 2>/dev/null || echo ""
    } > CHANGELOG_NEW.md

    mv CHANGELOG_NEW.md CHANGELOG.md
    rm -f CHANGELOG_TMP.md

    log_success "Changelog generated"
}

# Build all targets
build_all() {
    log_info "Building all targets..."
    if [[ "$DRY_RUN" != "--dry-run" ]]; then
        just build-all-targets
    else
        log_warn "DRY RUN: Skipping build"
    fi
}

# Create git tag
create_tag() {
    log_info "Creating git tag v$VERSION..."
    if [[ "$DRY_RUN" != "--dry-run" ]]; then
        git add -A
        git commit -m "chore: release v$VERSION"
        git tag -a "v$VERSION" -m "Release v$VERSION"
        log_success "Tag v$VERSION created"
    else
        log_warn "DRY RUN: Would create tag v$VERSION"
    fi
}

# Push to remote
push_changes() {
    log_info "Pushing changes..."
    if [[ "$DRY_RUN" != "--dry-run" ]]; then
        git push origin main --tags
        log_success "Pushed to origin"
    else
        log_warn "DRY RUN: Would push to origin"
    fi
}

# Create GitHub Release
create_github_release() {
    log_info "Creating GitHub Release..."
    if [[ "$DRY_RUN" != "--dry-run" ]]; then
        if command -v gh &> /dev/null; then
            # Extract changelog for this version
            local changelog
            changelog=$(awk "/^## \\[$VERSION\\]/,/^## \\[/" CHANGELOG.md | head -n -1 | tail -n +2)

            gh release create "v$VERSION" \
                --title "Blink Arcana v$VERSION" \
                --notes "$changelog" \
                --target main

            # Upload artifacts if they exist
            if [[ -d "build" ]]; then
                find build -type f -name "*" | while read -r file; do
                    gh release upload "v$VERSION" "$file" || true
                done
            fi

            log_success "GitHub Release created"
        else
            log_warn "gh CLI not found, skipping GitHub Release creation"
        fi
    else
        log_warn "DRY RUN: Would create GitHub Release"
    fi
}

# Docker push
docker_push() {
    log_info "Building and pushing Docker image..."
    if [[ "$DRY_RUN" != "--dry-run" ]]; then
        docker build -t "blink-arcana:$VERSION" -f docker/Dockerfile .
        docker tag "blink-arcana:$VERSION" "blink-arcana:latest"
        # docker push blink-arcana:$VERSION  # Uncomment when registry configured
        # docker push blink-arcana:latest
        log_success "Docker image built (push manually when registry ready)"
    else
        log_warn "DRY RUN: Would build Docker image"
    fi
}

# Main
main() {
    echo "=== Blink Arcana Release Script ==="
    echo "Version: $VERSION"
    echo "Dry run: ${DRY_RUN:-false}"
    echo ""

    if [[ -z "$VERSION" ]]; then
        log_error "Usage: $0 <version> [--dry-run]"
        exit 1
    fi

    validate_version
    check_clean
    check_branch
    run_ci_checks
    update_versions
    generate_changelog
    build_all
    create_tag
    push_changes
    create_github_release
    docker_push

    echo ""
    log_success "Release v$VERSION completed!"
    echo ""
    echo "Next steps:"
    echo "  - Verify GitHub Release: https://github.com/OWNER/blink-arcana/releases/tag/v$VERSION"
    echo "  - Check CI pipeline on pushed tag"
    echo "  - Announce release"
}

main "$@"
