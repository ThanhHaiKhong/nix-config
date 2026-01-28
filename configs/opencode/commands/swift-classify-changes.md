---
description: Intelligent change classification command that analyzes git modifications and determines optimal Swift build scope
---

Analyze git modifications and determine the optimal build scope for Swift projects using the swift-classify-changes script.

## Core Capabilities

This command analyzes git changes and classifies Swift files to determine the most efficient build strategy:

1. **Git Change Detection**:
   - Uses `git diff` to find modified Swift files
   - Supports staged, unstaged, and committed changes
   - Handles renamed and moved files

2. **Target Classification**:
   - Maps file paths to Swift package targets
   - Understands project structure (Features/Sources/, AppSchemas/, UIComponents/)
   - Handles different project types (Xcode workspace, Swift packages)

3. **Build Scope Determination**:
   - Single target → Build target only
   - Multiple targets in package → Build package
   - Cross-package changes → Build workspace/project
   - No Swift changes → Skip build

## Usage

Run this command to analyze git modifications and determine optimal build scope:

- `/swift-classify-changes` - Analyze current git changes
- `/swift-classify-changes --staged` - Analyze only staged changes
- `/swift-classify-changes --since origin/main` - Analyze changes since branch point

## Integration

This command integrates with the existing `~/.config/bin/swift-classify-changes` script to:
- Detect git modifications
- Classify files by target/package
- Determine optimal build scope (target/package/workspace)
- Provide structured output for build decision making
- Integrate with swift-build command for build execution

## Decision Matrix

The classification engine uses a sophisticated multi-factor analysis to determine optimal build scope:

### Primary Classification Factors

1. **File Type Analysis**
2. **Target Dependency Graph**
3. **Package Boundaries**
4. **Change Impact Assessment**
5. **Build Tool Capabilities**

### Advanced Decision Matrix

| Priority | Scenario | Files Changed | Dependencies | Build Scope | Command | Rationale |
|----------|----------|---------------|--------------|-------------|---------|-----------|
| 1 | **No Swift Changes** | Only non-Swift files (.md, .json, etc.) | N/A | Skip | No build | No compilation needed |
| 2 | **Resource Only** | Images, plists, storyboards in single target | Target only | Target | `swift build --target TargetName` | Resources don't affect other targets |
| 3 | **Generated Code** | Only auto-generated files | Depends on generator | Target/Package | `swift build --target TargetName` | Generated code scope depends on generator |
| 4 | **Test Only** | Only test files (*.Tests.swift) | Test target | Target | `swift build --target TargetName` | Tests don't affect main targets |
| 5 | **Single Target** | All files in one target directory | No external deps | Target | `swift build --target TargetName` | Minimal scope for isolated changes |
| 6 | **Single Target + Tests** | Target files + its test files | Test depends on target | Target | `swift build --target TargetName` | Tests require target to be built |
| 7 | **Multiple Targets (Same Package)** | Files across targets in same package | Internal deps | Package | `swift build --package-path PackagePath` | Package-level consistency needed |
| 8 | **Cross-Package Dependencies** | Files in Package A + Package B (A depends on B) | A → B | Workspace | `xcodebuild -workspace Workspace.xcworkspace` | Dependency chain requires full build |
| 9 | **Configuration Changes** | Package.swift, .xcworkspace modified | All dependents | Workspace | `xcodebuild -workspace Workspace.xcworkspace` | Config changes affect entire project |
| 10 | **Multiple Independent Packages** | Files in Package A + Package C (no deps) | Independent | Multi-Package | Build A then C separately | Parallel builds possible |

Always ensure the swift-classify-changes script exists and is executable before attempting to use this command. If it doesn't exist, you may need to install or create it.

#### Example 1: Single Target Change
```
Input: Only WeeklyList/WeeklyListStore.swift modified
Analysis: Single target, no external dependencies
Output: SCOPE:target, COMMAND:swift build --target WeeklyList, CONFIDENCE:0.9
```

#### Example 2: Cross-Target Dependencies
```
Input: WeeklyList/WeeklyListStore.swift + TodoListFeature/TodoListView.swift modified
Analysis: Multiple targets in same package, WeeklyList depends on AppSchemas
Output: SCOPE:package, COMMAND:swift build --package-path Features, CONFIDENCE:0.8
```

#### Example 3: Configuration Change
```
Input: Package.swift modified
Analysis: Configuration affects all dependents, high risk
Output: SCOPE:workspace, COMMAND:xcodebuild -workspace TodoList.xcworkspace, CONFIDENCE:0.95
```

#### Example 4: Test-Only Changes
```
Input: Only WeeklyListTests/WeeklyListTests.swift modified
Analysis: Test files only, minimal impact
Output: SCOPE:target, COMMAND:swift build --target WeeklyListTests, CONFIDENCE:0.85
```

#### Example 5: Resource-Only Changes
```
Input: Only Assets.xcassets modified
Analysis: Resources don't require compilation
Output: SCOPE:skip, COMMAND:none, CONFIDENCE:1.0
```

## Advanced Usage Patterns

**Manual Invocation**:
- `@swift-classify-changes` - Analyze current uncommitted changes
- `@swift-classify-changes --staged` - Analyze only staged changes
- `@swift-classify-changes --branch origin/main` - Analyze changes since branch
- `@swift-classify-changes --mode conservative` - Prefer safer, broader build scopes
- `@swift-classify-changes --mode optimistic` - Try minimal scopes first

**Integration with swift-build**:
- `@swift-build` automatically invokes you to determine build scope
- You provide structured output with multiple recommendations
- Fallback strategies for build failures

## Implementation Capabilities

### Advanced Analysis Engine
```bash
# Uses ~/.local/bin/swift-analyze-changes for comprehensive analysis
~/.local/bin/swift-analyze-changes unstaged          # Analyze uncommitted changes
~/.local/bin/swift-analyze-changes staged            # Analyze staged changes
~/.local/bin/swift-analyze-changes branch origin/main # Analyze since branch
```

### Multi-Factor Analysis
The analysis engine considers:

1. **Git Change Types**: Staged, unstaged, committed, branch comparisons
2. **File Classification**: Source, tests, resources, config, generated, docs
3. **Target Mapping**: Map files to Swift package targets with dependency awareness
4. **Dependency Graph**: Forward and reverse dependency analysis
5. **Risk Assessment**: Confidence scoring and fallback strategies

### Smart Scope Determination
```bash
# Decision factors:
# - File types and their compilation impact
# - Target interdependencies
# - Package boundaries
# - Configuration file changes
# - Test vs. production code changes
# - Generated vs. hand-written code
```

### Confidence-Based Recommendations
```bash
# Provides multiple build strategies:
# 1. Optimal scope (highest confidence)
# 2. Conservative fallback (safer option)
# 3. Full build (nuclear option)
# Each with confidence scores and risk assessments
```

### File Type Classification
```bash
# Categorize by file types and impact
SOURCE_FILES=$(echo "$CHANGES" | grep '\.swift$' | grep -v '\.Tests\.swift$')
TEST_FILES=$(echo "$CHANGES" | grep '\.Tests\.swift$')
RESOURCE_FILES=$(echo "$CHANGES" | grep -E '\.(xcassets|storyboard|plist)$')
CONFIG_FILES=$(echo "$CHANGES" | grep -E '(Package\.swift|\.xcworkspace|\.xcodeproj)$')
GENERATED_FILES=$(echo "$CHANGES" | grep -E '\.generated\.swift$')
```

### Dependency Graph Analysis
```bash
# Analyze import relationships
# Check target dependencies in Package.swift
# Identify reverse dependencies (who depends on modified targets)
```

### Risk Assessment
```bash
# Calculate confidence scores
# Identify potential build failure scenarios
# Provide fallback recommendations
```

### Incremental Build Detection
```bash
# Within a target, check if changes are isolated
# Analyze function/class dependencies
# Determine if full target rebuild is necessary
```

## Output Format

Provide structured analysis output:

```json
{
  "modified_files": [
    "Features/Sources/WeeklyList/WeeklyListStore.swift",
    "Features/Sources/TodoListFeature/TodoListView.swift"
  ],
  "targets_affected": ["WeeklyList", "TodoListFeature"],
  "build_scope": "package",
  "build_command": "swift build --package-path Features",
  "reasoning": "Multiple targets in Features package modified"
}
```

## Integration Points

**With swift-build subagent**:
- Primary input for determining build parameters
- Provides target/package/workspace scope decisions
- Enables intelligent selective building

**With Advanced Analysis Script**:
- Uses `~/.local/bin/swift-analyze-changes` for sophisticated analysis
- Provides dependency graph analysis
- Risk assessment and confidence scoring
- Multiple build strategy recommendations

**With Development Workflow**:
- Called automatically after file modifications
- Determines if build verification is needed
- Guides the build verification process with confidence scores

## Special Cases

**No Git Repository**:
```
Warning: Not in a git repository
Recommendation: Manual build verification required
```

**No Swift Files Modified**:
```
Info: No Swift files modified
Action: Skip build verification
```

**Mixed File Types**:
```
Files modified: 3 Swift files, 2 markdown files
Swift targets affected: WeeklyList, TodoListFeature
Build scope: package (Features)
```

## Advanced Analysis Features

### Dependency-Aware Classification

When analyzing changes, consider the dependency graph:

1. **Direct Dependencies**: Targets that the modified target depends on
2. **Reverse Dependencies**: Targets that depend on the modified target
3. **Transitive Dependencies**: Chain of dependencies that might be affected

### Platform-Specific Analysis

For multi-platform projects:
- Identify platform-specific code blocks (`#if os(iOS)`)
- Determine if changes affect only certain platforms
- Suggest platform-specific builds when safe

### Configuration Impact Assessment

Special handling for configuration changes:
- **Package.swift**: May require package resolution, affects all dependents
- **.xcworkspace**: Scheme/build configuration changes
- **.swiftlint.yml/.swift-format**: Linting/formatting rule changes
- **Info.plist**: App configuration changes

### Test Impact Analysis

Test file changes require careful consideration:
- Unit tests may only need their target built
- UI tests may require full app builds
- Integration tests may need multiple targets

### Generated Code Handling

Auto-generated files need special treatment:
- Identify code generation patterns
- Determine if generator scripts were modified
- Assess impact on dependent code

## Confidence Scoring

Provide confidence levels for recommendations:
- **High (0.8-1.0)**: Well-understood changes, low risk
- **Medium (0.5-0.8)**: Some uncertainty, moderate risk
- **Low (0.0-0.5)**: Complex changes, high risk, prefer broader builds

## Fallback Strategies

Always provide escalation paths:
1. **Primary Recommendation**: Optimal scope based on analysis
2. **Conservative Fallback**: Safer but slower option
3. **Full Build**: Nuclear option when uncertain

Always provide clear, actionable classification output with confidence scores, risk assessments, and multiple build strategy options to enable efficient and targeted Swift project building while minimizing build failures.