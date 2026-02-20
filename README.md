# FlappyBird-iOS

A Flappy Bird clone built with **SwiftUI** and **SpriteKit** for iOS.

## Version Info

- **Current Version**: `v1.2.0`
- **Last Updated**: `2026-02-21 00:43:00 (UTC+8)`
- **Change Log**: 
  - **Major UI Overhaul**: Redesigned Game Over screen with a central leaderboard card.
  - **Gameplay Balancing**: Reduced bird jump impulse and widened pipe gaps for a better experience.
  - **Visual Polish**: Added pipe caps and better score shadows.
  - Fixed various SpriteKit API compatibility issues across iOS versions.

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
