# GommitLint Action

WIP dont use yet


```yaml
steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0
  
  - name: Validate Commits
    id: lint
    uses: itiquette/gommitlint@v1
    with:
      comparebranch: 'main'

  - name: Check Results
    if: steps.lint.outputs.validation_status == 'failure'
    run: |
      echo "Found ${{ steps.lint.outputs.invalid_commits }} invalid commits"
      echo "Errors: ${{ steps.lint.outputs.validation_errors }}"
```
