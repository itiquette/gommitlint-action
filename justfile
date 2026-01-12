#!/usr/bin/env just --justfile

# SPDX-FileCopyrightText: The Gommitlint Action Authors
#
# SPDX-License-Identifier: EUPL-1.2

# just-check integration
devtools_repo := env("JUST_CHECK_REPO", "https://codeberg.org/itiquette/just-check")
devtools_dir := env("XDG_DATA_HOME", env("HOME") + "/.local/share") + "/just-check"
lint := devtools_dir + "/linters"

# Display available recipes
default:
    @printf "\033[1;36m gommitlint-action Just Recipes\033[0m\n\n"
    @just --list --unsorted

# ==================================================================================== #
# SETUP
# ==================================================================================== #

# Install mise and all development tools
[group('setup')]
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v mise &> /dev/null; then
        printf "Installing mise...\n"
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
    printf "Installing development tools via mise...\n"
    mise trust
    mise install
    just setup-devtools

# Setup just-check (clone or update)
[group('setup')]
setup-devtools:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -d "{{devtools_dir}}" ]]; then
        if [[ -f "{{devtools_dir}}/scripts/setup.sh" ]]; then
            "{{devtools_dir}}/scripts/setup.sh" "{{devtools_repo}}" "{{devtools_dir}}"
        fi
    else
        printf "Cloning just-check to %s...\n" "{{devtools_dir}}"
        mkdir -p "$(dirname "{{devtools_dir}}")"
        git clone --depth 1 "{{devtools_repo}}" "{{devtools_dir}}"
        git -C "{{devtools_dir}}" fetch --tags --depth 1 --quiet
        latest=$(git -C "{{devtools_dir}}" describe --tags --abbrev=0 origin/main 2>/dev/null || echo "")
        if [[ -n "$latest" ]]; then
            git -C "{{devtools_dir}}" fetch --depth 1 origin tag "$latest" --quiet
            git -C "{{devtools_dir}}" checkout "$latest" --quiet
        fi
        printf "Installed just-check %s\n" "${latest:-main}"
    fi

# ==================================================================================== #
# LINT (recipes expected by just-check)
# ==================================================================================== #

# Run all linters
[group('lint')]
lint: _ensure-devtools
    @{{devtools_dir}}/scripts/verify.sh

# Lint commits (disabled - this IS the commit linter action)
[group('lint')]
lint-commits:
    @# Disabled: This is the gommitlint action itself

# Lint YAML files
[group('lint')]
lint-yaml:
    @{{lint}}/yaml.sh check

# Lint shell scripts
[group('lint')]
lint-shell:
    @{{lint}}/shell.sh

# Check shell formatting
[group('lint')]
lint-shell-fmt:
    @{{lint}}/shell-fmt.sh check

# Verify license compliance (REUSE)
[group('lint')]
lint-license:
    @{{lint}}/license.sh

# Alias for lint-license (expected by just-check)
[group('lint')]
lint-reuse:
    @just lint-license

# Lint markdown files
[group('lint')]
lint-markdown:
    @{{lint}}/markdown.sh check MD013

# Scan for secrets
[group('lint')]
lint-secrets:
    @{{lint}}/secrets.sh

# Lint GitHub/Forgejo Actions
[group('lint')]
lint-actions:
    @{{lint}}/actions.sh

# Lint containers (disabled - no containers in this project)
[group('lint')]
lint-container:
    @# Disabled: No container files in this project

# Lint XML files (disabled - no XML in this project)
[group('lint')]
lint-xml:
    @# Disabled: No XML files in this project

# Run OpenSSF Scorecard (local mode)
[group('lint')]
scorecard:
    scorecard --local . --format default || true

# ==================================================================================== #
# FIX
# ==================================================================================== #

# Auto-fix all fixable issues
[group('fix')]
lint-fix: fix-yaml fix-shell fix-markdown
    @printf "All auto-fixes applied\n"

# Auto-fix YAML files
[group('fix')]
fix-yaml:
    @{{lint}}/yaml.sh fix

# Auto-fix shell scripts
[group('fix')]
fix-shell:
    @{{lint}}/shell-fmt.sh fix

# Auto-fix markdown files
[group('fix')]
fix-markdown:
    @{{lint}}/markdown.sh fix MD013

# ==================================================================================== #
# SECURITY
# ==================================================================================== #

# Scan for secrets in git history
[group('security')]
scan-secrets:
    gitleaks detect --source . --verbose

# Run OpenSSF Scorecard
[group('security')]
scan-scorecard:
    scorecard --local . --format json > scorecard-results.json || true
    @printf "Results saved to scorecard-results.json\n"

# ==================================================================================== #
# RELEASE (for local testing)
# ==================================================================================== #

# Generate changelog for a version (dry-run)
[group('release')]
changelog version:
    git-chglog --config .chglog/config.yml "{{version}}"

# Verify release signing setup
[group('release')]
verify-signing:
    #!/usr/bin/env bash
    set -euo pipefail
    printf "Checking signing tools...\n"
    command -v cosign &> /dev/null && printf "  cosign: $(cosign version 2>&1 | head -1)\n" || printf "  cosign: NOT FOUND\n"
    command -v witness &> /dev/null && printf "  witness: $(witness version 2>&1 | head -1)\n" || printf "  witness: NOT FOUND\n"
    printf "\nPublic keys (from profile repo):\n"
    printf "  https://codeberg.org/itiquette/profile/src/branch/main/keys/\n"

# ==================================================================================== #
# INTERNAL
# ==================================================================================== #

[private]
_ensure-devtools:
    @just setup-devtools
