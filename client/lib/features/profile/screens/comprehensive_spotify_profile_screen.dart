import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/providers/spotify_providers.dart';
import '../../../core/services/spotify_service.dart';
import '../../../core/widgets/aux_wars_button.dart';
import '../widgets/comprehensive_stats_card.dart';
import '../widgets/device_card.dart';
import '../widgets/currently_playing_card.dart';
import '../widgets/saved_content_tabs.dart';

class ComprehensiveSpotifyProfileScreen extends ConsumerStatefulWidget {
  const ComprehensiveSpotifyProfileScreen({super.key});

  @override
  ConsumerState<ComprehensiveSpotifyProfileScreen> createState() => _ComprehensiveSpotifyProfileScreenState();
}

class _ComprehensiveSpotifyProfileScreenState extends ConsumerState<ComprehensiveSpotifyProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late TabController _tabController;
  
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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _tabController = TabController(length: 4, vsync: this);

    _backgroundController.repeat();
    _cardController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    _tabController.dispose();
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
                // Background floating particles (matching aux wars)
                ...List.generate(25, (index) {
                  final offset = _backgroundController.value * 2 * math.pi;
                  final x = 0.5 + 0.4 * math.cos(offset + index * 0.3);
                  final y = 0.5 + 0.4 * math.sin(offset + index * 0.4);
                  return Positioned(
                    left: x * size.width,
                    top: y * size.height,
                    child: Container(
                      width: 3 + (index % 4) * 2,
                      height: 3 + (index % 4) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1DB954).withOpacity(0.05 + (index % 5) * 0.05),
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
                      
                      // Header with user info
                      _buildUserHeader(isMobile),
                      
                      const SizedBox(height: 24),

                      // Tab controller for different sections
                      _buildTabController(isMobile),

                      const SizedBox(height: 16),

                      // Tab content
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
              width: isMobile ? 32 : 36,
              height: isMobile ? 32 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1DB954),
                    const Color(0xFF1ed760),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: isMobile ? 16 : 20,
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

            SizedBox(width: isMobile ? 8 : 12),

            // Event info (aux wars style)
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
                      border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.5)),
                    ),
                    child: Text(
                      'PROFILE',
                      style: TextStyle(
                        color: const Color(0xFF1DB954),
                        fontSize: isMobile ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'COMPREHENSIVE SPOTIFY DATA',
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
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1DB954),
                    const Color(0xFF1ed760),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
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

  Widget _buildUserHeader(bool isMobile) {
    final profileAsync = ref.watch(spotifyComprehensiveProfileProvider);
    
    return profileAsync.when(
      data: (profile) {
        if (profile.user == null) return const SizedBox.shrink();
        
        return AnimatedBuilder(
          animation: _cardController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _cardController.value) * 50),
              child: Opacity(
                opacity: _cardController.value,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
                  padding: EdgeInsets.all(isMobile ? 20 : 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF1DB954).withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // User avatar with glow
                      Container(
                        width: isMobile ? 70 : 90,
                        height: isMobile ? 70 : 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1DB954),
                              const Color(0xFF1ed760),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: profile.user!.images.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  profile.user!.images.first.url,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: Colors.white,
                                size: isMobile ? 35 : 45,
                              ),
                      ),
                      
                      SizedBox(width: isMobile ? 16 : 20),
                      
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.user!.displayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isMobile ? 4 : 6),
                            
                            // User stats
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildInfoPill(
                                  '${profile.user!.followers} followers',
                                  Icons.people,
                                  Colors.blue,
                                  isMobile,
                                ),
                                _buildInfoPill(
                                  profile.user!.product.toUpperCase(),
                                  Icons.star,
                                  const Color(0xFF1DB954),
                                  isMobile,
                                ),
                                _buildInfoPill(
                                  profile.user!.country,
                                  Icons.location_on,
                                  Colors.purple,
                                  isMobile,
                                ),
                              ],
                            ),
                            
                            SizedBox(height: isMobile ? 8 : 12),
                            
                            // Quick stats
                            Row(
                              children: [
                                _buildQuickStat(
                                  '${profile.totalPlaylists}',
                                  'Playlists',
                                  isMobile,
                                ),
                                SizedBox(width: isMobile ? 16 : 20),
                                _buildQuickStat(
                                  '${profile.totalSavedTracks}',
                                  'Saved',
                                  isMobile,
                                ),
                                SizedBox(width: isMobile ? 16 : 20),
                                _buildQuickStat(
                                  '${profile.totalFollowedArtists}',
                                  'Following',
                                  isMobile,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => _buildLoadingHeader(isMobile),
      error: (error, stack) => _buildErrorHeader(error.toString(), isMobile),
    );
  }

  Widget _buildInfoPill(String text, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 10,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 12 : 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isMobile ? 10 : 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabController(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: TextStyle(
          fontSize: isMobile ? 11 : 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: isMobile ? 11 : 13,
          fontWeight: FontWeight.w500,
        ),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1DB954),
              const Color(0xFF1ed760),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1DB954).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        indicatorPadding: EdgeInsets.all(isMobile ? 4 : 6),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Library'),
          Tab(text: 'Activity'), 
          Tab(text: 'Devices'),
        ],
      ),
    );
  }

  Widget _buildTabContent(bool isMobile, bool isDesktop) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(isMobile),
        _buildLibraryTab(isMobile),
        _buildActivityTab(isMobile),
        _buildDevicesTab(isMobile),
      ],
    );
  }

  Widget _buildOverviewTab(bool isMobile) {
    final profileAsync = ref.watch(spotifyComprehensiveProfileProvider);
    
    return profileAsync.when(
      data: (profile) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
          child: Column(
            children: [
              // Comprehensive stats cards
              ComprehensiveStatsCard(
                profile: profile,
                isMobile: isMobile,
              ),
              
              const SizedBox(height: 20),
              
              // Currently playing
              if (profile.currentlyPlaying?.track != null) ...[
                CurrentlyPlayingCard(
                  currentlyPlaying: profile.currentlyPlaying!,
                  playerState: profile.playerState,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 20),
              ],
              
              // Top content preview
              _buildTopContentPreview(profile, isMobile),
              
              const SizedBox(height: 100), // Bottom padding
            ],
          ),
        );
      },
      loading: () => _buildLoadingContent(isMobile),
      error: (error, stack) => _buildErrorContent(error.toString(), isMobile),
    );
  }

  Widget _buildLibraryTab(bool isMobile) {
    final profileAsync = ref.watch(spotifyComprehensiveProfileProvider);
    
    return profileAsync.when(
      data: (profile) {
        return SavedContentTabs(
          profile: profile,
          isMobile: isMobile,
        );
      },
      loading: () => _buildLoadingContent(isMobile),
      error: (error, stack) => _buildErrorContent(error.toString(), isMobile),
    );
  }

  Widget _buildActivityTab(bool isMobile) {
    final profileAsync = ref.watch(spotifyComprehensiveProfileProvider);
    
    return profileAsync.when(
      data: (profile) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent activity
              _buildSectionHeader('Recent Activity', isMobile),
              const SizedBox(height: 12),
              ...profile.recentTracks.take(10).map((track) {
                return _buildTrackTile(track, isMobile);
              }),
              
              const SizedBox(height: 24),
              
              // Top tracks
              _buildSectionHeader('Top Tracks This Month', isMobile),
              const SizedBox(height: 12),
              ...profile.shortTermTracks.take(10).map((track) {
                return _buildTrackTile(track, isMobile);
              }),
              
              const SizedBox(height: 100),
            ],
          ),
        );
      },
      loading: () => _buildLoadingContent(isMobile),
      error: (error, stack) => _buildErrorContent(error.toString(), isMobile),
    );
  }

  Widget _buildDevicesTab(bool isMobile) {
    final profileAsync = ref.watch(spotifyComprehensiveProfileProvider);
    
    return profileAsync.when(
      data: (profile) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
          child: Column(
            children: [
              // Player state
              if (profile.playerState != null) ...[
                DeviceCard(
                  playerState: profile.playerState!,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 20),
              ],
              
              // Available devices
              if (profile.devices.isNotEmpty) ...[
                _buildSectionHeader('Available Devices', isMobile),
                const SizedBox(height: 12),
                ...profile.devices.map((device) {
                  return _buildDeviceTile(device, isMobile);
                }),
              ] else ...[
                _buildEmptyState('No devices available', Icons.devices, isMobile),
              ],
              
              const SizedBox(height: 100),
            ],
          ),
        );
      },
      loading: () => _buildLoadingContent(isMobile),
      error: (error, stack) => _buildErrorContent(error.toString(), isMobile),
    );
  }

  Widget _buildTopContentPreview(SpotifyProfileData profile, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Your Top Music', isMobile),
        const SizedBox(height: 16),
        
        // Top artists preview
        if (profile.shortTermArtists.isNotEmpty) ...[
          Text(
            'Top Artists',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: isMobile ? 80 : 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: math.min(10, profile.shortTermArtists.length),
              itemBuilder: (context, index) {
                final artist = profile.shortTermArtists[index];
                return _buildArtistCard(artist, isMobile);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Top tracks preview
        if (profile.shortTermTracks.isNotEmpty) ...[
          Text(
            'Top Tracks',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...profile.shortTermTracks.take(3).map((track) {
            return _buildTrackTile(track, isMobile);
          }),
        ],
      ],
    );
  }

  Widget _buildArtistCard(SpotifyArtist artist, bool isMobile) {
    return Container(
      width: isMobile ? 70 : 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: isMobile ? 50 : 65,
            height: isMobile ? 50 : 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1DB954).withOpacity(0.2),
              border: Border.all(
                color: const Color(0xFF1DB954).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: artist.images.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      artist.images.first.url,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: const Color(0xFF1DB954),
                    size: isMobile ? 20 : 25,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            artist.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTrackTile(SpotifyTrack track, bool isMobile) {
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
          // Album art
          Container(
            width: isMobile ? 40 : 50,
            height: isMobile ? 40 : 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF1DB954).withOpacity(0.2),
            ),
            child: track.album.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      track.album.images.last.url,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.music_note,
                    color: const Color(0xFF1DB954),
                    size: isMobile ? 16 : 20,
                  ),
          ),
          
          SizedBox(width: isMobile ? 12 : 16),
          
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  track.artists.map((a) => a.name).join(', '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isMobile ? 11 : 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Duration
          Text(
            _formatDuration(track.duration),
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(SpotifyDevice device, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: device.isActive 
            ? const Color(0xFF1DB954).withOpacity(0.2)
            : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: device.isActive 
              ? const Color(0xFF1DB954).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getDeviceIcon(device.type),
            color: device.isActive ? const Color(0xFF1DB954) : Colors.white60,
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  device.type.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          if (device.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ACTIVE',
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

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'computer':
        return Icons.computer;
      case 'smartphone':
        return Icons.phone_android;
      case 'speaker':
        return Icons.speaker;
      case 'tv':
        return Icons.tv;
      case 'game_console':
        return Icons.games;
      default:
        return Icons.devices;
    }
  }

  Widget _buildSectionHeader(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: isMobile ? 18 : 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildLoadingHeader(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
      height: isMobile ? 120 : 150,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
        ),
      ),
    );
  }

  Widget _buildErrorHeader(String error, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
            size: isMobile ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Failed to load profile: $error',
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

  Widget _buildLoadingContent(bool isMobile) {
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
            'Loading your music data...',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String error, bool isMobile) {
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
            'Failed to load data',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            error,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isMobile ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 20),
          AuxWarsButton(
            text: 'Retry',
            onPressed: () {
              ref.invalidate(spotifyComprehensiveProfileProvider);
            },
            icon: Icons.refresh,
            isMobile: isMobile,
            color: const Color(0xFF1DB954),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.5),
            size: isMobile ? 48 : 64,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
