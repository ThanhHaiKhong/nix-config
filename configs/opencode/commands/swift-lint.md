---
description: Intelligent Swift code linter using SwiftLint with auto-fixing and comprehensive rule checking
---

Lint Swift code using the swift-lint script with auto-fixing and comprehensive rule checking.

## Core Capabilities

This command uses the comprehensive linting script located at `~/.config/bin/swift-lint` that provides:

1. **Universal Swift Project Analysis**:
   - Lints entire projects or specific files
   - Auto-detects .swiftlint.yml configuration files
   - Supports git-based filtering (staged files, uncommitted changes)

2. **Multiple Analysis Modes**:
   - **Lint Mode**: Standard violation detection
   - **Fix Mode**: Auto-correct violations (--fix)
   - **Strict Mode**: Treat warnings as errors (--strict)
   - **Rule-specific**: Check only specific rules (--only-rule)

3. **Output Formats**:
   - Xcode format (default for IDE integration)
   - JSON, CSV, HTML, Markdown for different workflows
   - GitHub Actions logging for CI/CD

## Usage

Run this command to lint Swift code:

- `/swift-lint` - Lint current project with Xcode reporter
- `/swift-lint --fix` - Auto-fix violations
- `/swift-lint --strict` - Treat warnings as errors
- `/swift-lint --only-rule force_cast` - Check specific rule
- `/swift-lint --reporter json` - JSON output format
- `/swift-lint --git-diff` - Lint only uncommitted changes
- `/swift-lint --stats` - Show detailed statistics

## Integration

This command integrates with the existing `~/.config/bin/swift-lint` script to:
- Provide intelligent parameter selection based on context
- Handle different linting scenarios and outputs
- Integrate with the broader OpenCode workflow
- Guide users on rule configuration and fixing violations

## Linting Strategy

1. **Mode Selection**:
   - Default: Standard linting with Xcode reporter
   - With --fix: Attempt auto-correction of violations
   - With --strict: Enforce zero warnings policy

2. **Target Selection**:
   - Project-wide: Comprehensive analysis
   - Git changes: Focused on recent modifications
   - Specific rules: Targeted rule checking

3. **Configuration**:
   - Auto-detect .swiftlint.yml files
   - Use custom config when specified
   - Provide guidance on rule customization

## Common SwiftLint Rules

**Style Rules**:
- `opening_brace`: Opening brace spacing
- `trailing_whitespace`: Remove trailing whitespace
- `line_length`: Enforce maximum line length

**Safety Rules**:
- `force_cast`: Discourage force casting
- `force_try`: Discourage force try
- `force_unwrapping`: Discourage force unwrapping

**Best Practices**:
- `unused_closure_parameter`: Detect unused parameters
- `redundant_nil_coalescing`: Redundant nil coalescing
- `syntactic_sugar`: Prefer syntactic sugar

Always ensure the swift-lint script exists and SwiftLint tool is installed before attempting to use this command. If not available, you may need to install the required tools and configure rules appropriately.