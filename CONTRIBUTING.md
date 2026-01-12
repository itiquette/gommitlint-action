# Contributing

[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?style=for-the-badge&logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![Code of Conduct](https://img.shields.io/badge/Simple%20Code%20of%20Conduct-1.0-4baaaa.svg?style=for-the-badge)](CODE_OF_CONDUCT.md)
[![DCO - developer certificate of origin](https://img.shields.io/badge/DCO-Developer%20Certificate%20of%20Origin-lightyellow?style=for-the-badge)](https://developercertificate.org/)

Welcome! Thank you for contributing to gommitlint-action.

## Ways to Contribute

- Fix or report a bug
- Suggest enhancements
- Improve documentation
- Add examples or use cases

## Community Guideline

Be nice and respectful to each other. We follow the [Simple Contributor Code Of Conduct](CODE_OF_CONDUCT.md).

## File an Issue

Please check briefly if there already exists an Issue with your topic.

### Report a Bug

Open an Issue that summarizes the bug and set the label to "bug".

### Suggest a Feature

To request a new feature, summarize the desired functionality and its use case. Set the Issue label to "enhancement".

## Contribute Code

### Fork and Pull Request

1. Fork the repository and create a feature branch
2. Make your changes with proper commit messages
3. Submit a pull request to the main project
4. Address any review feedback

### Commit Guideline

**Two signing requirements:**

1. **DCO Sign-off** (`--signoff`): Certifies you have rights to contribute the code
2. **Cryptographic Signing** (`--gpg-sign`): Verifies commit authenticity

```bash
git commit --signoff --gpg-sign -m "fix: correct validation error message"
```

Use [Conventional Commits](https://www.conventionalcommits.org) format:

```text
type(scope): description

Types: feat, fix, docs, chore, refactor, test
```

### Development

This action is a thin wrapper around [gommitlint](https://codeberg.org/itiquette/gommitlint). For detailed contribution guidelines, see the [gommitlint CONTRIBUTING guide](https://codeberg.org/itiquette/gommitlint/src/branch/main/CONTRIBUTING.md).

## Reporting Security Issues

See [SECURITY.md](SECURITY.md) for how to report vulnerabilities.

## FOSS Standards

This project complies with:

- [REUSE specification](https://reuse.software/) for license compliance
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format
- [Keep-A-Changelog](https://keepachangelog.com/en/1.1.0/) format

**Happy contributing!**
