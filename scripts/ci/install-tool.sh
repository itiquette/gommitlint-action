#!/usr/bin/env bash
# SPDX-FileCopyrightText: The Gommitlint Action Authors
# SPDX-License-Identifier: EUPL-1.2
#
# Install a tool with checksum verification.
# This script provides a consistent, secure way to install CI tools.
#
# Usage: install-tool.sh <tool-name>
#
# The script reads version information from versions.env and verifies
# downloads against upstream checksum files.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source versions (shellcheck can't follow dynamic paths)
# shellcheck source=versions.env disable=SC1091
source "${SCRIPT_DIR}/versions.env"

verify_checksum() {
  local checksum_url="$1"
  local artifact_name="$2"
  local artifact_path="$3"
  local checksum_file
  local expected

  checksum_file=$(mktemp)
  curl -sSfL "${checksum_url}" -o "${checksum_file}"
  expected=$(grep " ${artifact_name}$" "${checksum_file}" | awk '{print $1}')

  if [[ -z "${expected}" ]]; then
    echo "ERROR: Could not find checksum for ${artifact_name} in ${checksum_url}"
    cat "${checksum_file}"
    rm -f "${checksum_file}"
    exit 1
  fi

  echo "${expected}  ${artifact_path}" | sha256sum -c
  rm -f "${checksum_file}"
}

install_tarball() {
  local name="$1"
  local version="$2"
  local url="$3"
  local checksum_url="$4"
  local binary="${5:-$name}"
  local dest="${6:-/usr/local/bin}"
  local archive_name="${url##*/}"

  echo "Installing ${name} ${version}..."
  cd /tmp
  curl -sSfL "${url}" -o "${archive_name}"
  verify_checksum "${checksum_url}" "${archive_name}" "${archive_name}"
  tar -xzf "${archive_name}" "${binary}"
  mv "${binary}" "${dest}/${binary}"
  chmod +x "${dest}/${binary}"
  rm -f "${archive_name}"
  echo "${name} ${version} installed successfully"
}

install_binary() {
  local name="$1"
  local version="$2"
  local url="$3"
  local checksum_url="$4"
  local dest="${5:-/usr/local/bin}"
  local artifact_name="${url##*/}"

  echo "Installing ${name} ${version}..."
  cd /tmp
  curl -sSfL "${url}" -o "${artifact_name}"
  verify_checksum "${checksum_url}" "${artifact_name}" "${artifact_name}"
  mv "${artifact_name}" "${dest}/${artifact_name}"
  chmod +x "${dest}/${artifact_name}"
  echo "${name} ${version} installed successfully"
}

case "${1:-}" in
just)
  install_tarball "just" "${JUST_VERSION}" \
    "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    "https://github.com/casey/just/releases/download/${JUST_VERSION}/SHA256SUMS"
  just --version
  ;;
scorecard)
  install_tarball "scorecard" "${SCORECARD_VERSION}" \
    "https://github.com/ossf/scorecard/releases/download/v${SCORECARD_VERSION}/scorecard_${SCORECARD_VERSION}_linux_amd64.tar.gz" \
    "https://github.com/ossf/scorecard/releases/download/v${SCORECARD_VERSION}/scorecard_checksums.txt"
  ;;
mise)
  dest="${2:-$HOME/.local/bin}"
  archive_name="mise-v${MISE_VERSION}-linux-x64-musl.tar.gz"
  mkdir -p "${dest}"
  echo "Installing mise ${MISE_VERSION}..."
  cd /tmp
  curl -sSfL "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/${archive_name}" -o "${archive_name}"
  verify_checksum "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/SHASUMS256.txt" "${archive_name}" "${archive_name}"
  tar -xzf "${archive_name}"
  mv mise/bin/mise "${dest}/mise"
  chmod +x "${dest}/mise"
  rm -rf "${archive_name}" mise
  echo "mise ${MISE_VERSION} installed successfully"
  ;;
witness)
  install_tarball "witness" "${WITNESS_VERSION}" \
    "https://github.com/in-toto/witness/releases/download/v${WITNESS_VERSION}/witness_${WITNESS_VERSION}_linux_amd64.tar.gz" \
    "https://github.com/in-toto/witness/releases/download/v${WITNESS_VERSION}/witness_${WITNESS_VERSION}_checksums.txt"
  witness version
  ;;
cosign)
  install_binary "cosign" "${COSIGN_VERSION}" \
    "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-amd64" \
    "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign_checksums.txt"
  cosign version
  ;;
git-chglog)
  install_tarball "git-chglog" "${GIT_CHGLOG_VERSION}" \
    "https://github.com/git-chglog/git-chglog/releases/download/v${GIT_CHGLOG_VERSION}/git-chglog_${GIT_CHGLOG_VERSION}_linux_amd64.tar.gz" \
    "https://github.com/git-chglog/git-chglog/releases/download/v${GIT_CHGLOG_VERSION}/checksums.txt" \
    git-chglog
  git-chglog --version
  ;;
gitleaks)
  install_tarball "gitleaks" "${GITLEAKS_VERSION}" \
    "https://github.com/zricethezav/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" \
    "https://github.com/zricethezav/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_checksums.txt" \
    gitleaks
  gitleaks version
  ;;
"" | --help | -h)
  echo "Usage: $0 <tool-name>"
  echo ""
  echo "Available tools:"
  echo "  just        - Command runner"
  echo "  scorecard   - OpenSSF Scorecard"
  echo "  mise        - Tool version manager"
  echo "  witness     - In-toto attestation"
  echo "  cosign      - Container/artifact signing"
  echo "  git-chglog  - Changelog generator"
  echo "  gitleaks    - Secret scanner"
  exit 0
  ;;
*)
  echo "Error: Unknown tool '${1}'"
  echo "Run '$0 --help' for available tools"
  exit 1
  ;;
esac
