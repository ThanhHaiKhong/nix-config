---
description: Intelligent Swift code formatter using Apple's swift-format with auto-detection and validation
---

Format Swift code using the swift-format script with auto-detection and validation.

## Core Capabilities

This command uses the comprehensive formatting script located at `~/.config/bin/swift-format` that provides:

1. **Universal Swift File Detection**:
   - Processes single files or entire directories
   - Auto-detects .swift-format configuration files
   - Supports git-based filtering (staged files, uncommitted changes)

2. **Multiple Formatting Modes**:
   - **Preview Mode**: Shows formatted output without modifying files
   - **In-place Mode**: Modifies files directly (--in-place)
   - **Validate Mode**: Checks if files are properly formatted (--validate)
   - **Parallel Processing**: Fast formatting with --parallel flag

3. **Configuration Support**:
   - Auto-detects .swift-format configuration files
   - Custom configuration file support
   - Git integration for selective formatting

## Usage

Run this command to format Swift code:

- `/swift-format` - Preview formatted output for current directory
- `/swift-format --in-place` - Format files in-place
- `/swift-format --validate` - Check if files are properly formatted
- `/swift-format MyFile.swift -i` - Format specific file
- `/swift-format --git-diff -i` - Format only uncommitted changes

## Integration

This command integrates with the existing `~/.config/bin/swift-format` script to:
- Provide intelligent parameter selection
- Handle different formatting scenarios
- Integrate with the broader OpenCode workflow
- Guide users on configuration and usage

## Formatting Strategy

1. **Mode Selection**:
   - Default: Preview mode (safe, shows changes)
   - With --in-place: Modify files directly
   - With --validate: Check compliance for CI/CD

2. **Target Selection**:
   - Single file: Format specific file
   - Directory: Recursive formatting
   - Git changes: Format only modified files

3. **Configuration**:
   - Auto-detect .swift-format files
   - Use custom config when specified
   - Fall back to default Apple style

Always ensure the swift-format script exists and swift-format tool is installed before attempting to use this command. If not available, you may need to install the required tools.