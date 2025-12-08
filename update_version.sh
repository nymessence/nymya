#!/bin/bash
# update_version.sh - Update version numbers across all project files

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <new_version>"
    echo "Example: $0 0.1.5"
    exit 1
fi

NEW_VERSION="$1"

# Validate version format (x.y.z or x.y.z-dev)
if ! [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+.*$ ]]; then
    echo "Error: Invalid version format. Use format like 0.1.5 or 0.1.5-alpha"
    exit 1
fi

echo "Updating NymyaLang project to version: $NEW_VERSION"
echo "=========================================="

# Get current version from the main Cargo.toml
if [ -f "nymyac/Cargo.toml" ]; then
    CURRENT_VERSION=$(grep -Po 'version = "\K[0-9]+\.[0-9]+\.[0-9]+(?=")' nymyac/Cargo.toml)
    echo "Current version in nymyac/Cargo.toml: $CURRENT_VERSION"
else
    echo "Error: nymyac/Cargo.toml not found!"
    exit 1
fi

# Update build script
echo "Updating build_deb_packages.sh..."
sed -i "s/VERSION=\${1:-\"[0-9]*\.[0-9]*\.[0-9]*\"}/VERSION=\${1:-\"$NEW_VERSION\"}/" build_deb_packages.sh

# Update main compiler Cargo.toml
echo "Updating nymyac/Cargo.toml..."
sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/g" nymyac/Cargo.toml

# Update build script version as well
echo "Updating build_deb_packages.sh version parameter..."
sed -i "s/VERSION=\${1:-\"$CURRENT_VERSION\"}/VERSION=\${1:-\"$NEW_VERSION\"}/" build_deb_packages.sh

# Update syntax highlighter install script
if [ -f "syntax_highlighter/install.sh" ]; then
    echo "Updating syntax_highlighter/install.sh..."
    sed -i "s/nymya-lang-$CURRENT_VERSION/nymya-lang-$NEW_VERSION/g" syntax_highlighter/install.sh
    sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$NEW_VERSION\"/g" syntax_highlighter/install.sh
else
    echo "Warning: syntax_highlighter/install.sh not found, skipping"
fi

# Update Windows cross-compilation test
if [ -f "test_windows_cross.sh" ]; then
    echo "Updating test_windows_cross.sh..."
    sed -i "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/g" test_windows_cross.sh
else
    echo "Warning: test_windows_cross.sh not found, skipping"
fi

# Update Docker test script
if [ -f "test_docker.sh" ]; then
    echo "Updating test_docker.sh..."
    sed -i "s/nymya-build-$CURRENT_VERSION/nymya-build-$NEW_VERSION/g" test_docker.sh
    sed -i "s/nymya_$CURRENT_VERSION/nymya_$NEW_VERSION/g" test_docker.sh
else
    echo "Warning: test_docker.sh not found, skipping"
fi

# Update documentation files
for doc_file in docs/DEBIAN_PACKAGE_BUILD_SYSTEM.md docs/DEBIAN_PACKAGE_README.md; do
    if [ -f "$doc_file" ]; then
        echo "Updating $doc_file..."
        # Replace version in a more conservative way
        sed -i "s/\(0\.[0-9]\+\.[0-9]\+\)/$NEW_VERSION/g" "$doc_file"
    else
        echo "Warning: $doc_file not found, skipping"
    fi
done

# Also update any files that contain the version
echo "Updating additional files that may contain version numbers..."
for file in $(find . -name "*.sh" -o -name "*.toml" -o -name "*.md" -o -name "*.txt" | grep -v "target" | grep -v "nymya-build-" | head -20); do
    if [ -f "$file" ] && [ "$file" != "./update_version.sh" ]; then
        if grep -q "$CURRENT_VERSION" "$file" 2>/dev/null; then
            echo "Updating version in $file..."
            sed -i "s/$CURRENT_VERSION/$NEW_VERSION/g" "$file"
        fi
    fi
done

echo ""
echo "Version updated from $CURRENT_VERSION to $NEW_VERSION"
echo ""
echo "Files updated:"
echo "- build_deb_packages.sh"
echo "- nymyac/Cargo.toml"
echo "- syntax_highlighter/install.sh (if exists)"
echo "- test_windows_cross.sh (if exists)"
echo "- test_docker.sh (if exists)"
echo "- Documentation files"
echo "- Other files containing the version"
echo ""
echo "Creating git commit..."

# Add all modified files to git
git add -A

git commit -m "Bump version to $NEW_VERSION

- Update version in build scripts
- Update version in package manifests
- Update version in documentation"

echo "Git commit created successfully!"
echo ""
echo "To complete the release, create a git tag with:"
echo "  git tag -a v$NEW_VERSION -m \"Release version $NEW_VERSION\""
echo ""
echo "Version update completed successfully!"