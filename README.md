# Socgent

Socgent is a lightweight iOS app for capturing a social link or ID, tagging it by platform, and keeping a recent list for quick reuse

## Features
- Paste a social link or handle and classify it by type
- Quick chips for social platforms
- Recent socials list with tap-to-use and delete
- Light/dark theme toggle

## Tech Stack
- SwiftUI
- The Composable Architecture (TCA)
- SwiftData for local persistence
- Moya for networking
- SwiftLint

## Requirements
- Xcode 16 or newer
- iOS 17.0+ deployment target

## Getting Started
1. Run xcodegen in your terminal
2. Open the project in Xcode:
   - `Socgent.xcodeproj`
3. Select the `Socgent` scheme and run on a simulator or device

## Development Notes
- SwiftLint runs as a build phase using `.swiftlint.yml`
- App configuration is defined in `project.yml` (XcodeGen)

## License
Copyright (c) Abdhilabs. All rights reserved.
