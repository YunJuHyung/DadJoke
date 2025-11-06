# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DadJoke is an iOS SwiftUI application that displays Korean "dad jokes" (아재개그) in a card-based interface. The app shows a question-answer format with animations and allows users to reveal answers and navigate through random jokes.

## Build and Run Commands

### Building and Running
- **Open project in Xcode**: `open DadJoke.xcodeproj`
- **Build from command line**: `xcodebuild -project DadJoke.xcodeproj -scheme DadJoke -configuration Debug build`
- **Run in simulator**: Open the project in Xcode and press Cmd+R

### Testing
This project does not currently have a test suite configured.

## Architecture

### Current Structure
The application currently uses a simple, single-view architecture:

- **DadJokeApp.swift**: Main app entry point using `@main` attribute
- **ContentView.swift**: Primary view containing the entire UI and joke display logic
  - Defines a local `Joke` struct with `question` and `answer` properties
  - Manages state with `@State` properties for current joke, answer visibility, and animations
  - Contains hardcoded array of jokes in Korean
  - Includes `ActionButton` component for bottom action buttons (heart, share, bookmark)

### Dual Data Model System
The project has two separate joke/gag data models that are not currently integrated:

1. **ContentView's Joke struct** (DadJoke/ContentView.swift:12-15)
   - Simple struct with `question` and `answer` strings
   - Currently used by the UI
   - Contains 11 hardcoded Korean jokes

2. **GagModel's Gag struct** (DadJoke/GagModel.swift:11-22)
   - More complete model conforming to `Codable` and `Identifiable`
   - Includes `id`, `title`, `content`, `category`, and `createdAt` properties
   - Supported by `MockGagAPIService` for async data fetching
   - **NOT currently used by the UI**

### Unused Components
- **Item.swift**: SwiftData model that appears to be template boilerplate, not used in the app
- **GagModel.swift**: Complete API service layer with mock data, error handling, and async/await patterns, but not integrated with ContentView

## Code Patterns

### State Management
- Uses `@State` for local view state (current joke, answer visibility, animations)
- No external state management (no ViewModel, ObservableObject, or StateObject patterns yet)

### UI Components
- SwiftUI declarative syntax with custom styling
- Animation using `withAnimation()` and `.spring()` modifiers
- Gradient backgrounds and shadow effects for visual polish
- Responsive layout with `Spacer()` and padding adjustments

### Future Integration Opportunity
The `MockGagAPIService` in GagModel.swift provides a ready-to-use service layer with:
- Singleton pattern (`MockGagAPIService.shared`)
- Async/await methods for fetching jokes
- Category filtering and random joke selection
- Custom `APIError` enum for error handling

To integrate this, ContentView would need to adopt the `Gag` model and use the async API methods instead of the local `jokes` array.

## Development Notes

### Language
- UI text is in Korean
- Code comments are in Korean
- Joke content is Korean wordplay/puns

### Project Structure
- Single target iOS app
- No external dependencies (uses only SwiftUI and Foundation)
- No Package.swift or Podfile (standard iOS project)
