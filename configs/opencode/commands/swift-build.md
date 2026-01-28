---
description: Intelligent Swift project builder that auto-detects project structure and builds modified Swift files
---

Build Swift projects using the swift-build script with intelligent detection of project structure and modified files.

## Core Capabilities

This command uses the powerful build script located at `~/.config/bin/swift-build` that provides:

1. **Universal Swift Project Detection**:
   - Auto-detects .xcworkspace, .xcodeproj, or Package.swift
   - Searches up to 10 directory levels to find project root
   - Supports workspaces, projects, and Swift packages

2. **Intelligent Build Execution**:
   - Supports all Apple platforms (iOS, macOS, tvOS, watchOS, visionOS)
   - Auto-selects appropriate build tools (xcodebuild vs swift build)
   - Handles clean builds and incremental builds

3. **Comprehensive Features**:
   - Path expansion (~, ./, ../)
   - Platform-specific SDK selection
   - Build destination management
   - Detailed output with colored formatting
   - Error handling and recovery suggestions

## Usage

Run this command to build Swift projects when files are modified:

- `/swift-build` - Auto-detect and build current project
- `/swift-build --platform macos` - Build for macOS
- `/swift-build --clean` - Clean build
- `/swift-build ~/path/to/project` - Build specific project

## Integration

This command integrates with the existing `~/.config/bin/swift-build` script to:
- Automatically detect project structure
- Build only what's necessary based on file modifications
- Provide enhanced error reporting and recovery

Always ensure the build script exists and is executable before attempting to use this command. If it doesn't exist, you may need to install or create it.