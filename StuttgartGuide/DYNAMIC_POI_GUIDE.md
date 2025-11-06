# Dynamic POI Discovery Guide

## Overview

The Stuttgart Audio Guide now features **dynamic POI discovery** that automatically finds tourist attractions in **any city worldwide**. No more hardcoding POIs - the app scales globally!

## Why Dynamic Discovery?

### Before (Hardcoded POIs)
❌ Only works in Stuttgart
❌ Manual research required for each POI
❌ Need code changes to add new cities
❌ Limited to 5 locations
❌ Doesn't scale

### After (Dynamic Discovery)
✅ Works in any city worldwide
✅ Automatic POI discovery
✅ No code changes needed
✅ Discovers up to 20+ POIs per area
✅ Infinitely scalable

---

## Architecture

### Three-Tier System

```
┌─────────────────────────────────────┐
│   1. MapKit (Default - FREE)        │
│   - Built into iOS                   │
│   - No API costs                     │
│   - Good coverage                    │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│   2. Curated POIs (Fallback)        │
│   - Handpicked quality locations    │
│   - Detailed descriptions           │
│   - Guaranteed accuracy             │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│   3. Google Places (Optional)       │
│   - Enhanced data                   │
│   - Ratings & reviews               │
│   - Requires API key                │
└─────────────────────────────────────┘
```

---

## How It Works

### Discovery Flow

```
User opens app
    ↓
LocationManager detects location
    ↓
POIDiscoveryService activates
    ↓
Searches 5km radius via MapKit
    ↓
Filters for tourist categories
    ↓
Sorts by distance
    ↓
Limits to top 20 POIs
    ↓
Merges with curated POIs
    ↓
Displays on map
    ↓
User approaches POI → Audio guide triggers
```

### Caching Strategy

- **Initial Discovery**: On first location update
- **Re-discovery Trigger**: When user moves >1km
- **Cache Duration**: Until location changes significantly
- **Duplicate Handling**: Removes POIs within 100m of each other

---

## Implementation Details

### 1. POIDiscoveryService.swift

**Purpose**: Discovers POIs using MapKit Local Search

**Key Features**:
- Searches 5km radius around user
- Filters for 11 tourist categories
- Returns up to 20 sorted POIs
- Generates descriptions based on category
- Caches results to minimize API calls

**Categories Discovered**:
```swift
- .museum
- .park
- .theater
- .castle
- .landmark
- .nationalPark
- .zoo
- .aquarium
- .library
- .stadium
- .publicTransport
```

**API Call Example**:
```swift
let service = POIDiscoveryService()
let pois = try await service.discoverPOIs(near: userLocation)
// Returns: [POI] sorted by distance
```

### 2. LocationManager Integration

**Enhanced LocationManager**:
- `availablePOIs`: Dynamic array of all POIs
- `useDynamicDiscovery`: Toggle for discovery mode
- `discoverPOIsNearby()`: Triggers discovery
- `mergePOIs()`: Combines hardcoded + discovered

**Discovery Trigger**:
```swift
// Automatically discovers on first location update
if !hasDiscoveredPOIs && useDynamicDiscovery {
    discoverPOIsNearby()
}
```

**Merge Logic**:
```swift
// Removes duplicates within 100m
- Compare hardcoded POIs with discovered
- If distance < 100m → Skip discovered
- Keeps curated POIs as priority
- Adds unique discovered POIs
```

### 3. POI Model Updates

**New Fields**:
```swift
let category: String?        // POI type (museum, park, etc.)
let phoneNumber: String?     // Optional contact
let url: URL?                // Optional website
let source: POISource        // hardcoded/mapKit/googlePlaces
```

**POISource Enum**:
```swift
enum POISource {
    case hardcoded      // Manually curated
    case mapKit         // Discovered via MapKit
    case googlePlaces   // Discovered via Google Places
}
```

### 4. UI Updates

**Toolbar Addition**:
- Shows POI count: "X POIs"
- Toggle button: 🌐 (dynamic) / 📖 (curated)
- Green = dynamic enabled
- Blue = curated only

**Map Updates**:
- Uses `locationManager.availablePOIs` (dynamic)
- Shows category icons
- Differentiates curated vs discovered

---

## Google Places API (Optional)

### Setup

1. **Get API Key**:
   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Enable Places API
   - Create credentials → API key
   - Restrict key to Places API

2. **Pricing** (as of 2024):
   - Nearby Search: $32 per 1000 requests
   - Place Details: $17 per 1000 requests
   - First $200/month free

3. **Integration**:
```swift
// In LocationManager or ContentView
let googleService = GooglePlacesService(apiKey: "YOUR_KEY")
let pois = try await googleService.discoverPOIs(near: location)
```

### GooglePlacesService.swift

**Methods**:
- `discoverPOIs(near:radius:)`: Find nearby attractions
- `getPlaceDetails(placeId:)`: Get detailed info

**Response Data**:
- Name, location, vicinity
- Place ID for details lookup
- Types/categories
- Geometry data

**Enhanced Features**:
```swift
// Place details include:
- Rating (1.0-5.0)
- User ratings count
- Formatted address
- Phone number
- Website
- Opening hours (future)
```

### When to Use Google Places

| Use Case | MapKit | Google Places |
|----------|--------|---------------|
| **Free tier** | ✅ Unlimited | ⚠️ $200/mo free |
| **Coverage** | ✅ Good | ✅ Excellent |
| **Details** | ⚠️ Basic | ✅ Comprehensive |
| **Privacy** | ✅ Native | ⚠️ Third-party |
| **Quality** | ✅ Reliable | ✅ Very detailed |
| **Commercial** | ✅ Free | 💰 Paid |

---

## Usage Examples

### Expanding to New Cities

#### Munich, Germany

```swift
// NO CODE NEEDED! Just:
1. Open app in Munich
2. App detects location (48.1351, 11.5820)
3. Discovers:
   - Marienplatz
   - English Garden
   - BMW Museum
   - Deutsches Museum
   - Nymphenburg Palace
   - Olympic Stadium
   - (+ 14 more)
```

#### Paris, France

```swift
// Still no code!
1. Open app in Paris
2. App detects location (48.8566, 2.3522)
3. Discovers:
   - Eiffel Tower
   - Louvre Museum
   - Notre-Dame
   - Arc de Triomphe
   - Sacré-Cœur
   - Musée d'Orsay
   - (+ 14 more)
```

#### Tokyo, Japan

```swift
// Works globally!
1. Open app in Tokyo
2. App detects location (35.6762, 139.6503)
3. Discovers:
   - Tokyo Tower
   - Senso-ji Temple
   - Imperial Palace
   - Meiji Shrine
   - Shibuya Crossing
   - Ueno Park
   - (+ 14 more)
```

### Custom Discovery Radius

Want to adjust the search radius?

```swift
// In POIDiscoveryService.swift
let region = MKCoordinateRegion(
    center: location.coordinate,
    latitudinalMeters: 10000,  // Change from 5000 to 10000 (10km)
    longitudinalMeters: 10000
)
```

### Adding Custom Categories

Want to discover restaurants or cafes?

```swift
// In POIDiscoveryService.swift
private let touristCategories: [MKPointOfInterestCategory] = [
    .museum,
    .park,
    // ... existing categories
    .restaurant,     // Add this
    .cafe,           // Add this
    .hotel,          // Add this
]
```

---

## Testing Dynamic Discovery

### In Simulator

```bash
1. Run app in simulator
2. Simulate location:
   - Menu: Features → Location → Custom Location

3. Test different cities:
   - Stuttgart: 48.7758, 9.1829
   - Munich: 48.1351, 11.5820
   - Berlin: 52.5200, 13.4050
   - Paris: 48.8566, 2.3522
   - London: 51.5074, -0.1278

4. Watch POI count in toolbar update
5. Tap POIs on map to see categories
```

### On Physical Device

```bash
1. Deploy to iPhone
2. Walk around any city
3. POIs auto-discover within 5km
4. Approach any POI → Audio guide plays
5. Toggle discovery mode to compare
```

### Debugging

Enable console logging:

```swift
// In POIDiscoveryService.swift
print("🔍 Discovering POIs near: \(location.coordinate)")
print("✅ Found \(pois.count) POIs")
print("📍 POIs: \(pois.map { $0.name })")
```

---

## Performance Considerations

### MapKit Local Search

- **Free**: Unlimited requests
- **Speed**: ~1-2 seconds per search
- **Radius**: 5km default
- **Limit**: Returns all matching POIs (we limit to 20)
- **Offline**: Requires internet connection

### Optimization Tips

1. **Cache aggressively**:
   - Only re-discover when moved >1km
   - Store discovered POIs in memory

2. **Limit results**:
   - Cap at 20 POIs to avoid UI clutter
   - Sort by distance for relevance

3. **Smart merging**:
   - Remove duplicates within 100m
   - Prioritize curated over discovered

4. **Background discovery**:
   - Discover asynchronously (already implemented)
   - Don't block UI thread

---

## Troubleshooting

### No POIs Discovered

**Symptoms**: POI count shows "0 POIs" or only curated POIs

**Solutions**:
1. Check internet connection
2. Verify location permissions granted
3. Ensure you're in an urban area (not desert/ocean)
4. Try different city coordinates
5. Check console for errors

**Debug**:
```swift
// Add to POIDiscoveryService
print("Search response: \(response.mapItems.count) items")
```

### Duplicate POIs

**Symptoms**: Same POI appears twice on map

**Solutions**:
1. Adjust duplicate threshold in LocationManager:
```swift
let duplicateThreshold: CLLocationDistance = 150 // Increase from 100
```

2. Check curated POI coordinates match real locations

### Wrong POI Categories

**Symptoms**: Restaurant showing as museum, etc.

**Solutions**:
1. MapKit data may be inaccurate - this is expected
2. Use Google Places for better categorization
3. Manually curate important POIs

### API Rate Limiting (Google Places only)

**Symptoms**: HTTP 429 errors

**Solutions**:
1. Implement request throttling
2. Upgrade Google Cloud quota
3. Fall back to MapKit on errors

---

## Future Enhancements

### Possible Improvements

1. **AI-Enhanced Discovery**:
   - Use Claude to analyze POI descriptions
   - Generate better short descriptions
   - Rank by interestingness score

2. **User Contributions**:
   - Let users suggest POIs
   - Community-curated lists
   - Rating system

3. **Offline Mode**:
   - Pre-download POI data for cities
   - Cache narrations
   - Work without internet

4. **Smart Recommendations**:
   - Learn user preferences
   - Suggest similar POIs
   - Walking tour routes

5. **Multi-Source Aggregation**:
   - Combine MapKit + Google + Wikipedia
   - Cross-reference for accuracy
   - Richer data

---

## API Comparison

### Feature Matrix

| Feature | MapKit | Google Places | Wikipedia API |
|---------|--------|---------------|---------------|
| **Cost** | Free | $17-32/1000 | Free |
| **Coverage** | Good | Excellent | Variable |
| **Speed** | Fast | Medium | Fast |
| **Details** | Basic | Comprehensive | Detailed |
| **Photos** | No | Yes | Yes |
| **Ratings** | No | Yes | No |
| **Hours** | No | Yes | No |
| **Privacy** | Best | Good | Best |
| **Setup** | None | API Key | None |

### Recommendation

**For MVP**: Use **MapKit** (current implementation)
- Free, fast, good enough
- Native iOS integration
- No API key management

**For Production**: Consider **MapKit + Google Places hybrid**
- MapKit for discovery
- Google Places for enhanced details
- Best of both worlds

---

## Code Examples

### Example 1: Discover POIs in Current City

```swift
let locationManager = LocationManager()

// Enable dynamic discovery (default)
locationManager.useDynamicDiscovery = true

// Discover POIs (automatic on location update)
// Access results:
print("Found \(locationManager.availablePOIs.count) POIs")
```

### Example 2: Toggle Discovery Mode

```swift
// Toggle button action
func toggleDiscovery() {
    locationManager.toggleDynamicDiscovery(!locationManager.useDynamicDiscovery)

    // Shows either:
    // - Dynamic: 5 curated + up to 15 discovered
    // - Curated: 5 curated only
}
```

### Example 3: Custom POI Filter

```swift
// In POIDiscoveryService
func discoverMuseumsOnly(near location: CLLocation) async throws -> [POI] {
    let request = MKLocalPointsOfInterestRequest(
        center: location.coordinate,
        radius: 5000
    )
    request.pointOfInterestFilter = MKPointOfInterestFilter(
        including: [.museum] // Only museums
    )

    let search = MKLocalSearch(request: request)
    let response = try await search.start()
    // ... process results
}
```

### Example 4: Add Google Places

```swift
// In ContentView setup
let googleService = GooglePlacesService(apiKey: "YOUR_API_KEY")

// In discovery flow
let googlePOIs = try await googleService.discoverPOIs(
    near: location,
    radius: 5000
)

// Merge with existing POIs
locationManager.availablePOIs += googlePOIs
```

---

## Summary

✅ **Dynamic POI discovery is now live!**

- Works in **any city worldwide**
- Uses **free MapKit** by default
- Optional **Google Places** for premium features
- **Zero code changes** to expand cities
- **Intelligent caching** for performance
- **Smart merging** of curated + discovered POIs

**Next Steps**:
1. Test in your city
2. Try toggling discovery mode
3. Compare curated vs discovered POIs
4. Consider Google Places if you need enhanced data

**Questions?** See main README.md or QUICKSTART.md

---

**Happy exploring! 🌍🎧**
