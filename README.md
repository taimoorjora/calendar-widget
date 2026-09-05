# Calendar Widget

A lightweight native macOS menu-bar calendar built with SwiftUI.

## Requirements

- macOS 13 or newer
- Xcode

Install Xcode from the Mac App Store, then open it once so it can finish
installing its development components.

## Open in Xcode

1. Open Xcode.
2. Choose **File → Open**.
3. Select this folder or its `Package.swift`.
4. Use Xcode to edit the Swift files and run the tests.

## Build the app

```sh
./scripts/build-app.sh
open "dist/Calendar Widget.app"
```

The build script creates a locally signed app bundle with no Dock icon. The
calendar symbol is shown by default; use the switch at the bottom of the
calendar to show today's date instead.
