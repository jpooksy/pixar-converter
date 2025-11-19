# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
- iOS app called "reed-test" - Pixar Style Image Converter
- Language: Swift
- UI Framework: SwiftUI
- Minimum iOS version: 15.0

## Build and Development Commands

### Building the Project
```bash
# Build for iOS Simulator
xcodebuild -project reed-test.xcodeproj -scheme reed-test -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' build

# Clean build
xcodebuild -project reed-test.xcodeproj -scheme reed-test clean build
```

### Running the App
Open `reed-test.xcodeproj` in Xcode and run with ⌘R, or use:
```bash
xcodebuild -project reed-test.xcodeproj -scheme reed-test -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17' run
```

## App Flow (MVP)
1. User uploads image from iPhone camera roll
2. App sends image to OpenAI GPT-4 Vision API to get description
3. App sends description + "Pixar style" prompt to DALL-E 3 API
4. App displays Pixar-styled result image
5. User can download result to device

## APIs Used
- OpenAI GPT-4 Vision API (analyze uploaded image)
- OpenAI DALL-E 3 API (generate Pixar-style version)
- Requires OpenAI API key

## File Structure

```
reed-test/
├── Models/
│   └── OpenAIModels.swift          # API request/response models for Vision & DALL-E
├── Services/
│   └── OpenAIService.swift         # OpenAI API integration layer
├── ViewModels/
│   └── PixarConverterViewModel.swift # App state and business logic
├── Utils/
│   └── ImagePicker.swift           # UIKit-SwiftUI photo picker wrapper
├── ContentView.swift               # Main UI view
└── reed_testApp.swift              # App entry point
```

## Architecture

### Data Flow
1. **ContentView** - User interface with image picker and result display
2. **PixarConverterViewModel** - Manages state and orchestrates the conversion process
3. **OpenAIService** - Handles API communication with OpenAI
4. **OpenAIModels** - Codable structs for API requests/responses

### Key Components
- `ImagePicker`: UIViewControllerRepresentable wrapper for accessing photo library
- `PixarConverterViewModel`: ObservableObject managing app state with @Published properties
- `OpenAIService`: Async/await based service layer for API calls

## Coding Standards
- Use SwiftUI for all views
- Use async/await for API calls
- Handle errors gracefully with user-friendly messages
- Show loading states during API calls
- Avoid force unwrapping (!)
- Use guard statements for early exits

## Setup Instructions

### First Time Setup
1. Open the project in Xcode: `open reed-test.xcodeproj`
2. Run the app on a simulator or device
3. Tap the key icon (🔑) in the top-right toolbar
4. Enter your OpenAI API key
5. Select an image from your photo library
6. Tap "Convert to Pixar Style"

### API Key Storage
- Currently stored in UserDefaults (for development)
- TODO: Migrate to Keychain for production security

## Important Notes
- Photo library permissions are configured in project build settings
- Images are compressed to JPEG at 80% quality before upload
- OpenAI API calls may take 10-30 seconds to complete
- Error messages are displayed inline with red background
- The app requires an active internet connection
