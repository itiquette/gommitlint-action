#!/usr/bin/env bash
# SPDX-FileCopyrightText: The Gommitlint Action Authors
# SPDX-License-Identifier: EUPL-1.2
#
# Commit CHANGELOG.md to main branch and move tag to include it.
# Uses SSH for both commit signing and pushing.
#
# Usage: commit-changelog.sh <version-tag> <repository>
# Example: commit-changelog.sh v0.5.1 itiquette/gommitlint-action
#
# Environment variables required:
#   SSH_SIGNING_KEY - SSH private key for commit signing and pushing

set -euo pipefail

VERSION="${1:-}"
REPOSITORY="${2:-}"

if [[ -z "$VERSION" || -z "$REPOSITORY" ]]; then
  echo "Usage: $0 <version-tag> <repository>" >&2
  echo "Example: $0 v0.5.1 itiquette/gommitlint-action" >&2
  exit 1
fi

if [[ -z "${SSH_SIGNING_KEY:-}" ]]; then
  echo "ERROR: SSH_SIGNING_KEY environment variable is required" >&2
  exit 1
fi

# Cleanup function to remove sensitive config on any exit
cleanup() {
  rm -f ~/.ssh/signing_key ~/.ssh/signing_key.pub ~/.ssh/config 2>/dev/null || true
}
trap cleanup EXIT

# Configure git for the release bot
git config user.name "Gommitlint Release Bot"
git config user.email "itiquette-release-bot@pm.me"

# Configure SSH key for both signing and pushing
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "$SSH_SIGNING_KEY" >~/.ssh/signing_key
chmod 600 ~/.ssh/signing_key
ssh-keygen -y -f ~/.ssh/signing_key >~/.ssh/signing_key.pub
chmod 644 ~/.ssh/signing_key.pub

# Configure SSH to use this key for github.com with connection multiplexing
cat >~/.ssh/config <<EOF
Host github.com
  IdentityFile ~/.ssh/signing_key
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new
  ControlMaster auto
  ControlPath ~/.ssh/ctrl-%r
  ControlPersist 20
EOF
chmod 600 ~/.ssh/config

# Configure git for SSH signing
git config gpg.format ssh
git config user.signingkey ~/.ssh/signing_key
git config commit.gpgsign true

# Use SSH remote URL instead of HTTPS
git remote set-url origin "git@github.com:${REPOSITORY}.git"

# Fetch and checkout main branch
git fetch origin main
git checkout main

# Generate CHANGELOG.md in Keep a Changelog format (after checkout so it's not lost)
git-chglog --config .chglog/config-keepachangelog.yml --output CHANGELOG.md
echo "Generated CHANGELOG.md ($(wc -l <CHANGELOG.md) lines)"

# Add and commit CHANGELOG.md if changed
if ! git diff --quiet CHANGELOG.md 2>/dev/null || [ ! -f CHANGELOG.md ]; then
  git add CHANGELOG.md

  # Generate minimal changelog for this version only (for commit body)
  git-chglog --config .chglog/config-minimal.yml "$VERSION" >commit-body.txt

  # Create commit message with changelog as body
  {
    printf 'chore(release): bump to %s\n\n' "$VERSION"
    cat commit-body.txt
    printf '\n[skip ci]\n'
  } >commit-msg.txt

  git commit -S -F commit-msg.txt --signoff
  rm -f commit-body.txt commit-msg.txt

  git push origin main

  # Move tag to include changelog commit (delete + recreate to avoid force push)
  OLD_TAG_COMMIT=$(git rev-parse "$VERSION")
  echo "Moving tag $VERSION from $OLD_TAG_COMMIT to $(git rev-parse HEAD)"

  git push origin :refs/tags/"$VERSION" # delete remote tag
  git tag -d "$VERSION"                 # delete local tag
  git tag -s "$VERSION" -m "$VERSION"   # create new tag at HEAD
  git push origin "$VERSION"            # push new tag

  echo "CHANGELOG.md committed and tag moved to include it"
else
  echo "CHANGELOG.md unchanged, skipping commit"
fi

# Return to the tag for any subsequent steps
git checkout "$VERSION"
