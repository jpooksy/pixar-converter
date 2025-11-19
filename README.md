# Pixar Style Image Converter

An iOS app that transforms your photos into Pixar-style animations using AI.

## Features

- 📸 Select any photo from your library
- 🤖 AI analyzes your image using GPT-4 Vision
- 🎨 Generates a Pixar-style version using DALL-E 3
- 💾 Save results to your photo library
- ⚡ No API key required - backend handles everything!

## How It Works

1. User selects an image from their iPhone
2. App sends image to our backend API
3. Backend uses OpenAI's GPT-4 Vision to analyze the image
4. Backend uses DALL-E 3 to generate a Pixar-style version
5. App displays and lets you save the result

## Setup Instructions

### Prerequisites

- macOS with Xcode installed
- iOS device or simulator

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/jpooksy/pixar-converter.git
   cd pixar-converter
   ```

2. Open the project in Xcode:
   ```bash
   open reed-test.xcodeproj
   ```

3. Select your device or simulator from the dropdown

4. Press ⌘R to build and run!

### Running on Your iPhone

1. Connect your iPhone to your Mac
2. Trust your Mac on your iPhone (if prompted)
3. In Xcode, select your iPhone from the device dropdown
4. Press ⌘R
5. On your iPhone, go to Settings → General → VPN & Device Management
6. Trust the developer certificate
7. Open the app!

## Using the App

1. Tap "Select Image from Library"
2. Choose a photo
3. Tap "Convert to Pixar Style"
4. Wait 20-40 seconds (AI is working!)
5. View your Pixar-style result
6. Tap "Save to Photos" to keep it

## Technical Details

### Architecture

- **Frontend**: SwiftUI iOS app
- **Backend**: Node.js serverless functions on Vercel
- **APIs**: OpenAI GPT-4 Vision + DALL-E 3

### Backend

The backend is already deployed and running at:
```
https://pixar-backend-seven.vercel.app
```

Rate limit: 10 conversions per hour per device

### Project Structure

```
pixar-converter/
├── reed-test/                      # iOS App Source
│   ├── ContentView.swift          # Main UI
│   ├── Services/
│   │   └── BackendService.swift   # API calls to backend
│   ├── ViewModels/
│   │   └── PixarConverterViewModel.swift
│   ├── Models/
│   │   └── OpenAIModels.swift
│   └── Utils/
│       └── ImagePicker.swift
├── backend/                        # Backend API (already deployed)
│   └── api/
│       ├── analyze-image.js       # GPT-4 Vision endpoint
│       └── generate-pixar.js      # DALL-E 3 endpoint
└── reed-test.xcodeproj
```

## Troubleshooting

**"Rate limit exceeded"**
- You've used 10 conversions in the last hour
- Wait an hour or ask the developer for increased limits

**"Failed to analyze image"**
- Check your internet connection
- Make sure the image isn't too large
- Try a different image

**App won't install on device**
- Make sure you trust the developer certificate in Settings
- Try cleaning the build (⌘⇧K) and rebuilding

## Notes

- Conversion takes 20-40 seconds (AI processing time)
- Works best with photos of people, pets, or scenes
- Images are compressed before upload for faster processing
- Your API usage is rate-limited to prevent abuse

## Cost

The app uses paid OpenAI APIs. Current cost per conversion:
- ~$0.045 per image conversion

## License

Personal project - feel free to explore and learn from the code!

---

Built with ❤️ using SwiftUI, OpenAI GPT-4 Vision, and DALL-E 3
