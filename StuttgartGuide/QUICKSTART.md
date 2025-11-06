# Quick Start Guide

Get up and running with Stuttgart Audio Guide in 5 minutes!

## Prerequisites Checklist

- [ ] macOS computer with Xcode 15.0+
- [ ] Claude API key ([Get one here](https://console.anthropic.com/))
- [ ] iOS device or simulator

## 3-Step Setup

### 1. Open in Xcode (30 seconds)

```bash
cd StuttgartGuide
open StuttgartGuide.xcodeproj
```

### 2. Configure Signing (1 minute)

1. Click project in Xcode sidebar
2. Select "StuttgartGuide" target
3. Go to "Signing & Capabilities"
4. Choose your Team
5. Done! ✓

### 3. Run the App (30 seconds)

1. Select destination (iPhone 15 Pro simulator or your device)
2. Press `Cmd + R`
3. Enter your Claude API key when prompted
4. Grant location permission
5. You're ready! 🎉

## Testing Without Going to Stuttgart

### Option 1: Simulator Location Simulation

1. Run app in simulator
2. Menu: Features → Location → Custom Location
3. Try these Stuttgart coordinates:
   - **Schlossplatz**: `48.7784, 9.1800`
   - **Fernsehturm**: `48.7557, 9.1900`

### Option 2: Device with Location Spoofing

1. Use tools like iTools or 3uTools
2. Set virtual location to Stuttgart
3. Test POI detection and narration

## How It Works

```
You approach POI (30m radius)
         ↓
App detects location
         ↓
Sends to Claude API with selected persona
         ↓
Generates custom narration
         ↓
Plays via text-to-speech
         ↓
Enjoy! 🎧
```

## First Steps

1. **Select a Persona**: Tap one of the 5 guide styles
2. **Check the Map**: See 5 Stuttgart POIs marked
3. **Simulate Location**: Move to a POI coordinate
4. **Listen**: Auto-plays narration when nearby
5. **Control**: Use play/pause/stop buttons

## Personas Explained

| Persona | Style | Best For |
|---------|-------|----------|
| 🏛️ History Buff | Deep historical context | History lovers |
| 🏗️ Architecture Expert | Design & structure details | Architecture fans |
| ⏱️ Concise Guide | 30-60 sec highlights | Quick visits |
| 😄 Comedian | Funny & quirky facts | Fun seekers |
| 👤 Local Insider | Hidden gems & tips | Authentic experiences |

## Common Issues

**"Location services disabled"**
→ Settings → Privacy → Location Services → Enable

**"API key invalid"**
→ Verify key from console.anthropic.com

**"No narration playing"**
→ Check internet connection & device volume

## Next Steps

- Try all 5 personas on the same POI
- Add more Stuttgart locations (see README.md)
- Customize persona prompts
- Test in real Stuttgart!

## Need Help?

See the full [README.md](README.md) for:
- Complete setup instructions
- Adding custom POIs
- Troubleshooting guide
- Architecture details

---

**Ready to explore? Open Xcode and let's go!** 🚀
