#!/bin/bash
set -e

# Release helper script
# Usage: ./release.sh [patch|minor|major]

if [ $# -eq 0 ]; then
    echo "Usage: $0 [patch|minor|major]"
    echo "Example: $0 patch"
    exit 1
fi

VERSION_TYPE=$1

# Check if we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Must be on main branch to create releases"
    exit 1
fi

# Check for uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Working directory has uncommitted changes"
    echo "Please commit or stash changes before creating a release"
    exit 1
fi

# Get current version from git tags
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CURRENT_VERSION=${CURRENT_VERSION#v}  # Remove 'v' prefix

echo "Current version: $CURRENT_VERSION"
echo "Release type: $VERSION_TYPE"

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case $VERSION_TYPE in
    patch)
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"
        ;;
    minor)
        NEW_MINOR=$((MINOR + 1))
        NEW_VERSION="$MAJOR.$NEW_MINOR.0"
        ;;
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_VERSION="$NEW_MAJOR.0.0"
        ;;
    *)
        echo "❌ Invalid version type. Use: patch, minor, or major"
        exit 1
        ;;
esac

NEW_TAG="v$NEW_VERSION"

echo "New version: $NEW_VERSION"
echo "New tag: $NEW_TAG"
echo ""

read -p "Create release $NEW_TAG? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo "🚀 Creating release $NEW_TAG..."

# Create and push tag
git tag "$NEW_TAG"
git push origin "$NEW_TAG"

echo "✅ Release $NEW_TAG created!"
echo "📦 GitHub Actions will automatically build and create the release."
echo "🔗 Check: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^.]*\).*/\1/')/releases"