# Stuttgart Audio Guide - MVP

A location-based audio guide app for iOS that provides AI-generated narrations of Stuttgart's points of interest through 5 unique guide personas.

## Features

- **5 Guide Personas:**
  - **History Buff**: Historical context and fascinating stories
  - **Architecture Expert**: Design, styles, and architects
  - **Concise Guide**: Quick 30-60 second facts
  - **Comedian**: Funny observations and quirky facts
  - **Local Insider**: Hidden gems and local culture

- **Dynamic POI Discovery**: Automatically discovers nearby tourist attractions using MapKit
  - Works in **any city worldwide** - not just Stuttgart!
  - Finds museums, landmarks, parks, theaters, and more
  - Toggle between dynamic discovery and curated POIs
  - Optional Google Places API integration for enhanced data

- **GPS Location Tracking**: Automatically detects when you're within 20-30 meters of a POI
- **AI-Generated Content**: Uses Claude API (claude-sonnet-4-5) for contextual narrations
- **Text-to-Speech**: Native iOS text-to-speech with play/pause/stop controls
- **Interactive Map**: Shows all POIs and tracks visited locations
- **Scalable Architecture**: Easily expand to new cities without code changes

## Stuttgart POIs Included

1. **Schlossplatz & Neues Schloss** - Baroque palace and central square
2. **Fernsehturm Stuttgart** - World's first concrete TV tower
3. **Staatstheater Stuttgart** - Premier opera house
4. **Markthalle Stuttgart** - Historic Art Nouveau market hall
5. **Stiftskirche** - 12th-century Protestant church

## Requirements

- macOS with Xcode 15.0 or later
- iOS 16.0+ device or simulator
- Claude API key from Anthropic
- Apple Developer account (for device deployment)

## Setup Instructions

### 1. Get Your Claude API Key

1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Sign in or create an account
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key (you'll need it when running the app)

### 2. Open the Project in Xcode

```bash
cd StuttgartGuide
open StuttgartGuide.xcodeproj
```

### 3. Configure Code Signing

1. In Xcode, select the project in the navigator
2. Select the "StuttgartGuide" target
3. Go to "Signing & Capabilities" tab
4. Select your Team from the dropdown
5. Xcode will automatically manage the provisioning profile

### 4. Build and Run

**For Simulator:**
1. Select an iPhone simulator from the scheme menu (e.g., iPhone 15 Pro)
2. Press `Cmd + R` to build and run
3. Note: Simulator requires manual location simulation

**For Physical Device:**
1. Connect your iPhone via USB
2. Trust your computer on the iPhone
3. Select your device from the scheme menu
4. Press `Cmd + R` to build and run
5. On first launch, you may need to trust the developer certificate:
   - Settings → General → VPN & Device Management → Trust your developer profile

### 5. First Launch Setup

1. Enter your Claude API key when prompted
2. Grant location permissions when requested
3. Select your preferred guide persona
4. Walk around Stuttgart (or simulate location for testing)

## Testing the App

### Testing in Simulator

1. Run the app in iOS Simulator
2. To simulate location:
   - In Simulator menu: Features → Location → Custom Location
   - Enter coordinates for a Stuttgart POI:
     - Schlossplatz: `48.7784, 9.1800`
     - Fernsehturm: `48.7557, 9.1900`
     - Staatstheater: `48.7809, 9.1854`
3. The app should detect the POI and generate narration

### Testing on Physical Device

1. Deploy to your iPhone
2. For testing without going to Stuttgart:
   - Download a GPS spoofing app (e.g., iTools)
   - Set your virtual location to Stuttgart POIs
3. For real-world testing:
   - Walk around Stuttgart with the app running
   - The app will automatically trigger when you approach POIs

## Usage Guide

### Basic Workflow

1. **Select Persona**: Choose your preferred guide style at the top
2. **Explore**: Walk around Stuttgart with the app open
3. **Automatic Narration**: When near a POI, the app:
   - Detects your proximity
   - Generates AI narration based on selected persona
   - Plays audio automatically
4. **Controls**: Use play/pause/stop buttons to control playback
5. **Map**: View your location and nearby POIs on the map

### Controls

- **Play/Pause Button**: Resume or pause current narration
- **Stop Button**: Stop playback and reset
- **Persona Selector**: Change guide style (takes effect on next POI)

### Tips

- Keep the app in foreground for best performance
- Ensure stable internet connection for AI generation
- Switch personas to get different perspectives on the same location
- Check the map to see which POIs you've visited (green checkmark)

## Dynamic POI Discovery

### How It Works

The app now **automatically discovers nearby tourist attractions** in any city! No need to hardcode POIs anymore.

**Features:**
- 🌍 **Works globally**: Munich, Berlin, Paris, London, anywhere!
- 🔍 **Auto-discovery**: Finds museums, landmarks, parks, theaters, etc.
- 🔄 **Toggle mode**: Switch between dynamic and curated POIs
- 📍 **Smart caching**: Avoids excessive API calls
- 🎯 **5km radius**: Discovers attractions within 5km of your location

### Using Dynamic Discovery

1. **Enable Dynamic Mode** (default): Tap the globe icon (🌐) in the toolbar
   - Globe icon = Dynamic discovery enabled
   - Book icon = Using curated POIs only

2. **How it discovers**:
   - When you first open the app, it scans your area
   - Finds up to 20 nearby tourist attractions
   - Merges with curated POIs for best results
   - Updates when you move >1km away

3. **POI Categories Discovered**:
   - Museums and galleries
   - Historic landmarks
   - Parks and nature reserves
   - Theaters and cultural venues
   - Castles and fortifications
   - Stadiums and sports venues
   - Libraries
   - Zoos and aquariums

### Expanding to New Cities

**No code changes needed!** Just:

1. Open the app in any city
2. Enable dynamic discovery (globe icon)
3. The app automatically finds attractions
4. Walk around and explore!

**Example cities:**
- 🇩🇪 **Munich**: Marienplatz, English Garden, BMW Museum
- 🇩🇪 **Berlin**: Brandenburg Gate, Museum Island, Reichstag
- 🇫🇷 **Paris**: Eiffel Tower, Louvre, Notre-Dame
- 🇬🇧 **London**: Big Ben, Tower Bridge, British Museum
- 🇮🇹 **Rome**: Colosseum, Vatican, Trevi Fountain

### Optional: Google Places Integration

For even better POI data, you can add Google Places API support:

1. Get a Google Places API key ([Get one here](https://developers.google.com/maps/documentation/places/web-service/get-api-key))
2. The app already has `GooglePlacesService.swift` ready
3. Modify `LocationManager` to use Google Places instead of MapKit
4. Benefit: Better descriptions, ratings, photos, opening hours

**Why MapKit by default?**
- ✅ **Free** - No API costs
- ✅ **Native** - Built into iOS
- ✅ **Privacy** - No third-party data sharing
- ✅ **Good coverage** - Works well for major attractions

**When to use Google Places?**
- Need detailed information (ratings, reviews, photos)
- Want better categorization
- Operating commercially with budget for API costs

## Adding More Curated POIs

To add additional points of interest:

1. Open `StuttgartGuide/Models/POI.swift`
2. Add new entries to the `stuttgartPOIs` array:

```swift
POI(
    name: "Your POI Name",
    coordinate: CLLocationCoordinate2D(latitude: YOUR_LAT, longitude: YOUR_LONG),
    radius: 30, // Detection radius in meters
    shortDescription: "Brief description of the location"
)
```

3. Find coordinates using:
   - Google Maps (right-click → "What's here?")
   - Apple Maps (right-click → "Share My Location")
   - GPS coordinates websites

### Example POIs to Add

```swift
// Mercedes-Benz Museum
POI(
    name: "Mercedes-Benz Museum",
    coordinate: CLLocationCoordinate2D(latitude: 48.7885, longitude: 9.2347),
    radius: 30,
    shortDescription: "Automotive history and innovation"
)

// Wilhelma Zoo & Botanical Garden
POI(
    name: "Wilhelma",
    coordinate: CLLocationCoordinate2D(latitude: 48.8041, longitude: 9.2051),
    radius: 40,
    shortDescription: "Historic zoological-botanical garden"
)

// Königstraße
POI(
    name: "Königstraße",
    coordinate: CLLocationCoordinate2D(latitude: 48.7761, longitude: 9.1810),
    radius: 25,
    shortDescription: "Main shopping street"
)
```

## Customizing Personas

To modify persona system prompts:

1. Open `StuttgartGuide/Models/Persona.swift`
2. Edit the `systemPrompt` property for each persona
3. Adjust tone, style, and focus areas

**Prompt Engineering Tips:**
- Keep prompts focused on audio tour format
- Specify desired length (e.g., 2-3 paragraphs)
- Define the persona's expertise and tone
- Remind the AI to be conversational for TTS

## Architecture Overview

```
StuttgartGuide/
├── App/
│   └── StuttgartGuideApp.swift          # App entry point
├── Models/
│   ├── Persona.swift                     # Guide persona definitions
│   ├── POI.swift                         # Point of interest model
│   └── AudioGuide.swift                  # App state management
├── Services/
│   ├── LocationManager.swift             # GPS tracking & geofencing
│   ├── ClaudeAPIService.swift            # API integration
│   └── TextToSpeechService.swift         # TTS playback
├── Views/
│   ├── ContentView.swift                 # Main coordinator view
│   ├── PersonaSelectorView.swift         # Persona selection UI
│   ├── MapView.swift                     # Map display
│   └── AudioControlsView.swift           # Playback controls
└── Info.plist                            # Location permissions
```

## Technical Details

### Location Tracking

- **Accuracy**: `kCLLocationAccuracyNearestTenMeters`
- **Distance Filter**: Updates every 10 meters
- **Background**: Disabled by default (can be enabled)
- **Geofencing**: Circle radius around each POI

### API Integration

- **Model**: `claude-sonnet-4-5-20250929`
- **Max Tokens**: 1024
- **Timeout**: Standard URLSession timeout
- **Error Handling**: Graceful fallbacks with user alerts

### Text-to-Speech

- **Engine**: AVSpeechSynthesizer (iOS native)
- **Language**: English (en-US)
- **Rate**: 0.9x default (for clarity)
- **Controls**: Play, pause, resume, stop

### Battery Optimization

- Location updates pause automatically when idle
- TTS stops when app backgrounds
- API calls only on POI proximity

## Troubleshooting

### Location Not Updating

- Check Settings → Privacy & Security → Location Services → StuttgartGuide
- Ensure "While Using the App" is enabled
- Try restarting location services in Settings

### No Narration Generated

- Verify Claude API key is correct
- Check internet connection
- Review Xcode console for API errors
- Ensure Claude API has available credits

### TTS Not Playing

- Check device volume and mute switch
- Ensure device is not in Silent mode
- Try toggling play/pause
- Restart the app

### Build Errors

- Clean build folder: Product → Clean Build Folder (`Cmd + Shift + K`)
- Update Xcode to latest version
- Check iOS deployment target is set to 16.0+

## Future Enhancements

**Potential features for future versions:**

- [ ] Background location tracking with notifications
- [ ] Offline mode with pre-downloaded narrations
- [ ] Multiple languages support
- [ ] User-generated POIs
- [ ] Social sharing of favorite narrations
- [ ] Walking tours with connected POIs
- [ ] Audio caching to reduce API calls
- [ ] Different TTS voices per persona
- [ ] Historical photos integration
- [ ] AR view for POI discovery

## API Costs

**Approximate costs (as of 2024):**

- Claude Sonnet 4.5: ~$3 per 1M input tokens, ~$15 per 1M output tokens
- Average narration: ~500 input tokens + ~300 output tokens
- Cost per narration: ~$0.006 (less than a penny)
- 100 POI visits: ~$0.60

## Privacy & Permissions

- **Location**: Used only to detect nearby POIs
- **Network**: Required for Claude API calls
- **No Data Collection**: All data stays on device
- **API Key**: Stored locally, never transmitted elsewhere

## License

This is a demonstration project. Feel free to modify and extend it for your own use.

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review Xcode console for errors
3. Verify all setup steps were completed

## Credits

- Built with SwiftUI
- Powered by Claude AI (Anthropic)
- Location data from Apple CoreLocation
- TTS from AVFoundation

---

**Enjoy exploring Stuttgart with your AI audio guide!** 🇩🇪🎧
