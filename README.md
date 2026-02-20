# FlappyBird-iOS

A Flappy Bird clone built with **SwiftUI** and **SpriteKit** for iOS.

## Version Info

- **Current Version**: `v1.1.2`
- **Last Updated**: `2026-02-21 00:38:00 (UTC+8)`
- **Change Log**: 
  - Fixed Full-Screen display issue on modern iPhones (Info.plist & SafeArea).
  - Fixed Pipe Generation issue (relaxed guards and improved spawn timing).
  - Improved character responsiveness and start speed.

## Features

- **SwiftUI Integration**: Uses `SpriteView` to host the game scene.
- **SpriteKit Engine**: Leverages iOS native 2D game engine for physics and rendering.
- **Core Gameplay**:
  - Tap to jump.
  - Procedural pipe generation.
  - Collision detection and score tracking.

## Getting Started

### Prerequisites

- macOS with Xcode installed.
- Command Line Tools.

### How to Run

1.  Clone the repository:
    ```bash
    git clone https://github.com/tusinami/FlappyBird-iOS.git
    cd FlappyBird-iOS
    ```

2.  Build and run in the Simulator:
    ```bash
    # Build for simulator
    xcodebuild -scheme FlappyBird -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -configuration Release build

    # Create app bundle and install (Custom steps for CLI only setup)
    mkdir -p FlappyBird.app
    cp /Users/$(whoami)/Library/Developer/Xcode/DerivedData/FlappyBird-*/Build/Products/Release-iphonesimulator/FlappyBird FlappyBird.app/
    # (Info.plist is required in the app bundle)
    ```

3.  Or simply open `Package.swift` in Xcode and click **Run**.

## Controls

- **Click/Tap**: Make the bird fly upwards.
- **Goal**: Pass through as many pipe gaps as possible without hitting them or the ground.

## License

MIT
