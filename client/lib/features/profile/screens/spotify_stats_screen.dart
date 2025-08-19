import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/providers/spotify_providers.dart';
import '../widgets/stats_card.dart';
import '../widgets/track_tile.dart';
import '../widgets/artist_tile.dart';
import '../widgets/mood_visualization.dart';

class SpotifyStatsScreen extends ConsumerStatefulWidget {
  const SpotifyStatsScreen({super.key});

  @override
  ConsumerState<SpotifyStatsScreen> createState() => _SpotifyStatsScreenState();
}

class _SpotifyStatsScreenState extends ConsumerState<SpotifyStatsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  String _selectedTimeRange = 'short_term';
  int _selectedTabIndex = 0;

  final List<Color> _gradientColors = [
    const Color(0xFF1DB954), // Spotify green
    const Color(0xFF1ed760),
    const Color(0xFF121212), // Spotify dark
    const Color(0xFF191414),
  ];

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController.repeat();
    _cardController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: _gradientColors,
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Stack(
              children: [
                // Background floating particles
                ...List.generate(20, (index) {
                  final offset = _backgroundController.value * 2 * math.pi;
                  final x = 0.5 + 0.3 * math.cos(offset + index * 0.3);
                  final y = 0.5 + 0.3 * math.sin(offset + index * 0.4);
                  return Positioned(
                    left: x * size.width,
                    top: y * size.height,
                    child: Container(
                      width: 4 + (index % 3) * 2,
                      height: 4 + (index % 3) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1DB954)
                            .withOpacity(0.1 + (index % 4) * 0.1),
                      ),
                    ),
                  );
                }),

                // Top bar
                _buildTopBar(context, isDesktop, isMobile),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // Header
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 32),
                        child: Column(
                          children: [
                            Text(
                              'Your Music Stats',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 28 : 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Discover your musical personality',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Time range selector
                            _buildTimeRangeSelector(isMobile),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tab selector
                      _buildTabSelector(isMobile),

                      const SizedBox(height: 16),

                      // Content
                      Expanded(
                        child: _buildTabContent(isMobile, isDesktop),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop, bool isMobile) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            // Spotify logo
            Container(
              width: isMobile ? 28 : 32,
              height: isMobile ? 28 : 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1DB954),
              ),
              child: Icon(
                Icons.show_chart,
                color: Colors.white,
                size: isMobile ? 14 : 18,
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            // Navigation arrows
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white70,
                size: isMobile ? 18 : 24,
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            // Title
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
                      'ANALYTICS',
                      style: TextStyle(
                        color: const Color(0xFF1DB954),
                        fontSize: isMobile ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'SPOTIFY MUSIC INSIGHTS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Premium badge
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
                'Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 8 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(bool isMobile) {
    const timeRanges = [
      ('4 Weeks', 'short_term'),
      ('6 Months', 'medium_term'),
      ('All Time', 'long_term'),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: timeRanges.map((range) {
          final isSelected = _selectedTimeRange == range.$2;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTimeRange = range.$2;
              });
              ref.invalidate(spotifyTopTracksProvider);
              ref.invalidate(spotifyTopArtistsProvider);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF1DB954) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF1DB954).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                range.$1,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabSelector(bool isMobile) {
    const tabs = [
      ('Overview', Icons.dashboard_outlined),
      ('Tracks', Icons.music_note_outlined),
      ('Artists', Icons.person_outline),
      ('Mood', Icons.psychology_outlined),
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      padding: EdgeInsets.all(isMobile ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF1DB954) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF1DB954).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      tab.$2,
                      color: isSelected ? Colors.white : Colors.white70,
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      tab.$1,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: isMobile ? 10 : 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(bool isMobile, bool isDesktop) {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(spotifyStatsProvider);

        return statsAsync.when(
          data: (stats) {
            switch (_selectedTabIndex) {
              case 0:
                return _buildOverviewTab(stats, isMobile);
              case 1:
                return _buildTracksTab(stats, isMobile);
              case 2:
                return _buildArtistsTab(stats, isMobile);
              case 3:
                return _buildMoodTab(stats, isMobile);
              default:
                return const SizedBox.shrink();
            }
          },
          loading: () => _buildLoadingState(isMobile),
          error: (error, stack) => _buildErrorState(error, isMobile),
        );
      },
    );
  }

  Widget _buildOverviewTab(SpotifyStats stats, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Column(
        children: [
          // Stats cards row
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Tracks',
                  value: stats.totalTracksAnalyzed.toString(),
                  icon: Icons.music_note,
                  color: const Color(0xFF1DB954),
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: StatsCard(
                  title: 'Artists',
                  value: stats.totalArtists.toString(),
                  icon: Icons.person,
                  color: Colors.purple,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 12 : 16),

          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Variety Score',
                  value: '${stats.varietyScore.toInt()}%',
                  icon: Icons.analytics,
                  color: Colors.orange,
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: StatsCard(
                  title: 'Playlists',
                  value: stats.playlists.length.toString(),
                  icon: Icons.playlist_play,
                  color: Colors.blue,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Top genres
          if (stats.topGenres.isNotEmpty) ...[
            _buildSectionHeader('Top Genres', isMobile),
            const SizedBox(height: 12),
            _buildGenresList(stats.topGenres, isMobile),
            SizedBox(height: isMobile ? 20 : 24),
          ],

          // Recent activity preview
          _buildSectionHeader('Recent Activity', isMobile),
          const SizedBox(height: 12),
          ...stats.recentTracks.take(3).map((track) => TrackTile(
                track: track,
                isMobile: isMobile,
              )),

          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildTracksTab(SpotifyStats stats, bool isMobile) {
    final tracks = _selectedTimeRange == 'short_term'
        ? stats.shortTermTracks
        : stats.mediumTermTracks;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        return TrackTile(
          track: tracks[index],
          isMobile: isMobile,
          rank: index + 1,
        );
      },
    );
  }

  Widget _buildArtistsTab(SpotifyStats stats, bool isMobile) {
    final artists = _selectedTimeRange == 'short_term'
        ? stats.shortTermArtists
        : stats.mediumTermArtists;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        return ArtistTile(
          artist: artists[index],
          isMobile: isMobile,
          rank: index + 1,
        );
      },
    );
  }

  Widget _buildMoodTab(SpotifyStats stats, bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Column(
        children: [
          MoodVisualization(
            stats: stats,
            isMobile: isMobile,
          ),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isMobile) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGenresList(List<String> genres, bool isMobile) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: genres.take(8).map((genre) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1DB954).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF1DB954).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            genre
                .split(' ')
                .map((word) => word[0].toUpperCase() + word.substring(1))
                .join(' '),
            style: TextStyle(
              color: const Color(0xFF1DB954),
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isMobile ? 60 : 80,
            height: isMobile ? 60 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1DB954).withOpacity(0.2),
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            'Analyzing your music...',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: isMobile ? 60 : 80,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Text(
            'Failed to load stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            'Check your Spotify connection',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
