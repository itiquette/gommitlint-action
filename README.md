# gommitlint-action

<div align="center">

[![GitHub Release](https://img.shields.io/github/v/release/itiquette/gommitlint-action?style=for-the-badge&color=green)](https://github.com/itiquette/gommitlint-action/releases)

[![License: EUPL-1.2](https://img.shields.io/badge/License-EUPL--1.2-blue?style=for-the-badge)](LICENSE)
[![REUSE](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.reuse.software%2Fstatus%2Fgithub.com%2Fitiquette%2Fgommitlint-action&query=status&style=for-the-badge&label=REUSE&color=lightblue)](https://api.reuse.software/info/github.com/itiquette/gommitlint-action)

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/itiquette/gommitlint-action/badge?style=for-the-badge)](https://scorecard.dev/viewer/?uri=github.com/itiquette/gommitlint-action)

GitHub Action to validate git commit messages using [gommitlint](https://codeberg.org/itiquette/gommitlint).

</div>

## Quick Start

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0

- run: git fetch origin main:main

- uses: itiquette/gommitlint-action@v0.8.1
  with:
    base-branch: main
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `config` | Path to gommitlint configuration file | No | - |
| `base-branch` | Base branch to compare against (e.g., `main`) | No | - |
| `range` | Commit range to validate (e.g., `HEAD~5..HEAD`, `main..HEAD`) | No | - |
| `count` | Validate last N commits from HEAD | No | - |
| `rules` | Only validate specific rules (comma-separated) | No | - |
| `exclude-rules` | Exclude specific rules (comma-separated) | No | - |
| `format` | Output format: `text`, `json`, `forgejo`, `github`, `gitlab` | No | `github` |
| `verbose` | Increase output verbosity for debugging | No | `false` |
| `log-level` | Log level: `error`, `warn`, `info`, `debug`, `trace` | No | - |
| `skip-verification` | Skip binary checksum verification (not recommended) | No | `false` |

> **Note**: Use either `base-branch`, `range`, OR `count` - not multiple.

## Examples

### Validate PR Commits

```yaml
name: Validate Commits

on:
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: itiquette/gommitlint-action@v0.8.1
        with:
          range: ${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}
```

### Validate Last N Commits

```yaml
- uses: itiquette/gommitlint-action@v0.8.1
  with:
    range: HEAD~5..HEAD
```

### Only Check Conventional Commits

```yaml
- uses: itiquette/gommitlint-action@v0.8.1
  with:
    base-branch: main
    rules: conventional
```

### Skip Signature Checks

```yaml
- uses: itiquette/gommitlint-action@v0.8.1
  with:
    base-branch: main
    exclude-rules: cryptosignature,signoff
```

### Allow Merge Commits

```yaml
- uses: itiquette/gommitlint-action@v0.8.1
  with:
    base-branch: main
    exclude-rules: linearhistory
```

### With Configuration File

```yaml
- uses: itiquette/gommitlint-action@v0.8.1
  with:
    config: .gommitlint.yaml
    base-branch: main
```

## Configuration

For advanced options like `ignore_commits`, `allow_fixup_commits`, spell checking, and more, use a `.gommitlint.yaml` configuration file. See the [gommitlint documentation](https://codeberg.org/itiquette/gommitlint#configuration) for all available options.

## Troubleshooting

### "fatal: bad revision" Error

This occurs when git can't find a referenced commit or branch. For `base-branch: main` or `range: main..HEAD`:

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Full history, not just latest commit

- run: git fetch origin main:main  # Fetch main branch ref

- uses: itiquette/gommitlint-action@v0.8.1
  with:
    base-branch: main
```

### Validation Fails on Merge Commits

The `LinearHistory` rule (enabled by default) rejects merge commits to enforce a rebase workflow. If disabled, merge commits are simply skipped by other rules - they pass through without validation.

To allow merge commits, disable the rule in your `.gommitlint.yaml`:

```yaml
gommitlint:
  rules:
    disabled:
      - linearhistory
```

## Recommended Permissions

The action only requires read access to repository contents:

```yaml
permissions:
  contents: read
```

## Related Projects

- [gommitlint](https://codeberg.org/itiquette/gommitlint) - The commit message linter
- [gommitlint-action (Forgejo)](https://codeberg.org/itiquette/gommitlint-action) - Forgejo Actions version

## License

EUPL-1.2
