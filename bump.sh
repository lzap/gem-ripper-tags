#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.2.1"
  exit 1
fi

NEW_VERSION="$1"
GEMSPEC_FILE="gem-ripper-tags.gemspec"

# Validate version format (basic semver check)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z (e.g., 1.2.1)"
  exit 1
fi

# Check if gemspec exists
if [ ! -f "$GEMSPEC_FILE" ]; then
  echo "Error: $GEMSPEC_FILE not found"
  exit 1
fi

# Update version in gemspec
echo "Updating version to $NEW_VERSION in $GEMSPEC_FILE..."
sed -i "s/s\.version\s*=\s*['\"].*['\"]/s.version     = \"$NEW_VERSION\"/" "$GEMSPEC_FILE"

# Verify the change
if ! grep -q "s.version.*$NEW_VERSION" "$GEMSPEC_FILE"; then
  echo "Error: Failed to update version in $GEMSPEC_FILE"
  exit 1
fi

echo "Version updated successfully in $GEMSPEC_FILE"

# Commit the version change
echo "Committing version change..."
git add "$GEMSPEC_FILE"
git commit -m "chore: bump version to $NEW_VERSION"

# Create git tag on the new commit
echo "Creating git tag $NEW_VERSION..."
git tag -a "$NEW_VERSION" -m "Release version $NEW_VERSION"

echo ""
echo "✓ Version bumped to $NEW_VERSION"
echo "✓ Changes committed"
echo "✓ Git tag $NEW_VERSION created"
echo ""
echo "Next steps:"
echo "  1. Review changes: git show $NEW_VERSION"
echo "  2. Push commit and tag: git push && git push origin $NEW_VERSION"
echo "  3. Build gem: gem build $GEMSPEC_FILE"
echo "  4. Publish: gem push gem-ripper-tags-$NEW_VERSION.gem"
