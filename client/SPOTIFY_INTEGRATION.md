# Spotify Music Stats Integration

This integration provides beautiful Spotify music statistics that match your Aux Wars design language. It includes comprehensive analytics, mood visualization, and a clean UI that follows your app's aesthetic.

## 🎵 Features

- **User Activity**: Recently played tracks, top artists, and listening habits
- **Music Analytics**: Detailed stats including danceability, energy, valence, and more
- **Mood Visualization**: Beautiful circular visualization of your music personality
- **Top Charts**: Your most played tracks and artists with time range filtering
- **Aux Wars Design**: Matches the design language of your existing aux wars screen
- **Responsive**: Works perfectly on mobile and desktop

## 🚀 Quick Start

### 1. Set up Spotify Developer Account

1. Visit [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Note down your **Client ID** and **Client Secret**
4. Get your **Refresh Token** using Spotify Web API Console or OAuth flow

### 2. Initialize the Service

```dart
// In your app initialization or specific screen
final spotifyService = ref.read(spotifyServiceProvider);

spotifyService.initialize(
  clientId: 'your_client_id_here',
  clientSecret: 'your_client_secret_here', 
  refreshToken: 'your_refresh_token_here',
  accessToken: 'your_access_token_here', // Optional
);
```

### 3. Add to Your App

You can integrate the Spotify stats in multiple ways:

#### Option A: Use the Complete Screens
```dart
// Navigate to setup screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const SpotifySetupScreen()),
);

// Or directly to stats (after setup)
Navigator.push(
  context, 
  MaterialPageRoute(builder: (context) => const SpotifyStatsScreen()),
);
```

#### Option B: Use Individual Components
```dart
// Use the providers directly
Consumer(
  builder: (context, ref, child) {
    final statsAsync = ref.watch(spotifyStatsProvider);
    return statsAsync.when(
      data: (stats) => YourCustomWidget(stats: stats),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  },
)
```

#### Option C: Add to Existing Screens
```dart
// Add stats to your profile screen
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Your existing profile content
        
        // Add Spotify stats section
        const SpotifyStatsSection(),
        
        // More content
      ],
    );
  }
}
```

## 🎨 Design Components

All components follow your Aux Wars design language:

### Buttons
```dart
AuxWarsButton(
  text: 'Connect Spotify',
  onPressed: () => _connectSpotify(),
  icon: Icons.music_note,
  color: Color(0xFF1DB954),
  isMobile: isMobile,
)

AuxWarsPill(
  text: '6 Months',
  isSelected: selectedRange == '6months',
  onPressed: () => setState(() => selectedRange = '6months'),
  isMobile: isMobile,
)
```

### Stats Cards
```dart
StatsCard(
  title: 'Total Tracks',
  value: '1,234',
  icon: Icons.music_note,
  color: Color(0xFF1DB954),
  isMobile: isMobile,
)
```

### Track & Artist Tiles
```dart
TrackTile(
  track: spotifyTrack,
  isMobile: isMobile,
  rank: 1, // Optional ranking
)

ArtistTile(
  artist: spotifyArtist,
  isMobile: isMobile,
  rank: 1, // Optional ranking
)
```

## 📊 Available Data

The service provides access to:

### User Data
- Profile information
- Follower count
- Account type (Free/Premium)
- Profile pictures

### Track Data
- Recently played tracks
- Top tracks (4 weeks, 6 months, all time)
- Track details (name, artist, album, duration)
- Popularity scores
- Audio features (danceability, energy, valence, etc.)

### Artist Data
- Top artists by time range
- Artist details (name, genres, followers)
- Artist images
- Popularity scores

### Analytics
- Listening variety score
- Dominant mood analysis
- Average audio features
- Top genres
- Playlist count

## 🎯 Providers

The integration uses Riverpod providers for clean state management:

```dart
// Core providers
spotifyServiceProvider        // The main service instance
spotifyCurrentUserProvider    // Current user info
spotifyStatsProvider         // Combined analytics data

// Specific data providers
spotifyRecentlyPlayedProvider // Recent tracks
spotifyTopTracksProvider     // Top tracks by time range
spotifyTopArtistsProvider    // Top artists by time range
spotifyCurrentlyPlayingProvider // What's playing now
spotifyUserPlaylistsProvider // User's playlists
```

## 🎨 Customization

### Colors
The components use your Spotify green theme by default, but you can customize:

```dart
AuxWarsButton(
  text: 'Custom Button',
  color: Colors.purple,  // Custom color
  onPressed: () {},
)
```

### Responsive Design
All components automatically adapt to screen size:
- Mobile: Compact layout, smaller fonts
- Desktop: Spacious layout, larger elements

### Animation
Components include smooth animations that match your aux wars screen:
- Button press animations
- Loading states
- Smooth transitions
- Background particle effects

## 🔧 Advanced Usage

### Custom Stats Calculations
```dart
// Access raw data for custom calculations
Consumer(
  builder: (context, ref, child) {
    final statsAsync = ref.watch(spotifyStatsProvider);
    return statsAsync.when(
      data: (stats) {
        // Calculate custom metrics
        final customScore = calculateYourMetric(stats.audioFeatures);
        return YourCustomStatsWidget(score: customScore);
      },
      // ...
    );
  },
)
```

### Error Handling
```dart
// Custom error handling
ref.listen<AsyncValue<SpotifyStats>>(spotifyStatsProvider, (prev, next) {
  next.whenOrNull(
    error: (error, stack) {
      // Show custom error UI
      showDialog(context: context, builder: (context) => CustomErrorDialog());
    },
  );
});
```

## 📱 Integration Examples

Check the `example_integration.dart` file for a complete implementation showing:
- How to initialize the service
- How to build screens using the components
- How to handle loading and error states
- How to match your Aux Wars design language

## 🎵 Spotify API Limits

Keep in mind Spotify API rate limits:
- 100 requests per minute per user
- Some endpoints have lower limits
- The service automatically handles token refresh

## 🔒 Security

- Store credentials securely (use flutter_secure_storage in production)
- Never commit API keys to version control
- Use environment variables or secure storage for sensitive data

## 🎨 Design Inspiration

This integration is designed to seamlessly blend with your Aux Wars aesthetic:
- Same gradient backgrounds
- Matching button styles
- Consistent typography
- Familiar color schemes
- Smooth animations
- Responsive layouts

The components will feel like a natural part of your existing app while providing powerful music analytics and insights.

## 🚀 Next Steps

1. Set up your Spotify Developer account
2. Add the components to your app
3. Customize colors and styling to match your brand
4. Add the stats screens to your navigation
5. Consider adding music-based social features using the data

Enjoy building amazing music experiences! 🎵
