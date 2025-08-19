// COMPREHENSIVE SPOTIFY INTEGRATION - MAXIMIZING API USAGE
// Example integration of the Comprehensive Spotify Profile Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your new Spotify components
import 'lib/core/providers/spotify_providers.dart';
import 'lib/features/profile/screens/comprehensive_spotify_profile_screen.dart';
import 'lib/features/profile/screens/spotify_oauth_screen.dart';
import 'lib/core/services/spotify_service.dart';
import 'lib/core/widgets/aux_wars_button.dart';
import 'lib/features/profile/screens/spotify_setup_screen.dart';
import 'lib/features/profile/screens/spotify_stats_screen.dart';
import 'lib/features/profile/screens/music_stats_launcher.dart';

// Example of how to integrate Spotify stats into your app
void main() {
  runApp(const ProviderScope(child: MyMusicApp()));
}

class MyMusicApp extends StatelessWidget {
  const MyMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Social Platform',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1DB954),
        scaffoldBackgroundColor: const Color(0xFF121212),
        fontFamily: 'GoogleSans', // Use your app's font
      ),
      // Start with the launcher screen for demo purposes
      home: const MusicStatsLauncher(),
    );
  }
}

// Example of how to use the Spotify service in your existing screens
class ExampleSpotifyIntegration extends ConsumerStatefulWidget {
  const ExampleSpotifyIntegration({super.key});

  @override
  ConsumerState<ExampleSpotifyIntegration> createState() =>
      _ExampleSpotifyIntegrationState();
}

class _ExampleSpotifyIntegrationState
    extends ConsumerState<ExampleSpotifyIntegration> {
  @override
  void initState() {
    super.initState();
    // Initialize Spotify service with your credentials
    _initializeSpotify();
  }

  void _initializeSpotify() {
    final spotifyService = ref.read(spotifyServiceProvider);

    // Replace these with your actual credentials
    spotifyService.initialize(
      clientId: 'ef70d1eaf2954852adcb645cf0c1ff8d',
      clientSecret: '1ffec02abceb4f42816073567d70ce59',
      refreshToken: 'YOUR_REFRESH_TOKEN',
      // accessToken: 'YOUR_ACCESS_TOKEN', // Optional
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1DB954), // Same colors as your aux wars screen
              Color(0xFF1ed760),
              Color(0xFF121212),
              Color(0xFF191414),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Your existing aux wars-style top bar
              _buildTopBar(isMobile),

              // Content area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    children: [
                      // Current user info
                      _buildCurrentUserSection(isMobile),

                      const SizedBox(height: 24),

                      // Quick stats
                      _buildQuickStats(isMobile),

                      const SizedBox(height: 24),

                      // Recently played preview
                      _buildRecentlyPlayed(isMobile),

                      const SizedBox(height: 24),

                      // Action buttons
                      _buildActionButtons(isMobile),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Row(
        children: [
          // Spotify logo (similar to your aux wars design)
          Container(
            width: isMobile ? 28 : 32,
            height: isMobile ? 28 : 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1DB954),
            ),
            child: Icon(
              Icons.music_note,
              color: Colors.white,
              size: isMobile ? 14 : 18,
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Title section (similar to aux wars)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: isMobile ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DB954).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: const Color(0xFF1DB954).withOpacity(0.5)),
                  ),
                  child: Text(
                    'MUSIC STATS',
                    style: TextStyle(
                      color: const Color(0xFF1DB954),
                      fontSize: isMobile ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  'YOUR SPOTIFY ACTIVITY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Premium badge (matching aux wars style)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF1DB954),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Connected',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 8 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserSection(bool isMobile) {
    final userAsync = ref.watch(spotifyCurrentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1DB954).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // User avatar
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 50 : 60,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1DB954),
                ),
                child: user.images.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.images.first.url,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        color: Colors.white,
                        size: isMobile ? 24 : 30,
                      ),
              ),

              SizedBox(width: isMobile ? 12 : 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.product.toUpperCase(),
                            style: TextStyle(
                              color: const Color(0xFF1DB954),
                              fontSize: isMobile ? 10 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${user.followers} followers',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => _buildLoadingCard(isMobile),
      error: (error, stack) =>
          _buildErrorCard('Failed to load user info', isMobile),
    );
  }

  Widget _buildQuickStats(bool isMobile) {
    final statsAsync = ref.watch(spotifyStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Tracks',
                stats.totalTracksAnalyzed.toString(),
                Icons.music_note,
                const Color(0xFF1DB954),
                isMobile,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: _buildStatCard(
                'Artists',
                stats.totalArtists.toString(),
                Icons.person,
                Colors.purple,
                isMobile,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: _buildStatCard(
                'Mood',
                stats.moodProfile.dominantMood,
                Icons.psychology,
                Colors.orange,
                isMobile,
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          Expanded(child: _buildLoadingCard(isMobile)),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(child: _buildLoadingCard(isMobile)),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(child: _buildLoadingCard(isMobile)),
        ],
      ),
      error: (error, stack) =>
          _buildErrorCard('Failed to load stats', isMobile),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayed(bool isMobile) {
    final recentAsync = ref.watch(spotifyRecentlyPlayedProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Played',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        recentAsync.when(
          data: (tracks) {
            return Column(
              children: tracks.take(3).map((track) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Album art placeholder
                      Container(
                        width: isMobile ? 40 : 48,
                        height: isMobile ? 40 : 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF1DB954).withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.album,
                          color: Colors.white,
                          size: isMobile ? 16 : 20,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              track.artists.map((a) => a.name).join(', '),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isMobile ? 10 : 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(3, (index) => _buildLoadingCard(isMobile)),
          ),
          error: (error, stack) =>
              _buildErrorCard('Failed to load recent tracks', isMobile),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Column(
      children: [
        AuxWarsButton(
          text: 'View Full Stats',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SpotifyStatsScreen(),
            ),
          ),
          icon: Icons.analytics,
          isMobile: isMobile,
          width: double.infinity,
          color: const Color(0xFF1DB954),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          children: [
            Expanded(
              child: AuxWarsButton(
                text: 'Setup',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SpotifySetupScreen(),
                  ),
                ),
                icon: Icons.settings,
                isMobile: isMobile,
                color: Colors.purple,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: AuxWarsButton(
                text: 'Refresh',
                onPressed: () {
                  ref.invalidate(spotifyStatsProvider);
                  ref.invalidate(spotifyCurrentUserProvider);
                  ref.invalidate(spotifyRecentlyPlayedProvider);
                },
                icon: Icons.refresh,
                isMobile: isMobile,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard(bool isMobile) {
    return Container(
      height: isMobile ? 60 : 80,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: isMobile ? 16 : 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
