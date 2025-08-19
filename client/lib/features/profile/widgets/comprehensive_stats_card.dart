import 'package:flutter/material.dart';
import '../../../core/services/spotify_service.dart';

class ComprehensiveStatsCard extends StatefulWidget {
  final SpotifyProfileData profile;
  final bool isMobile;

  const ComprehensiveStatsCard({
    super.key,
    required this.profile,
    required this.isMobile,
  });

  @override
  State<ComprehensiveStatsCard> createState() => _ComprehensiveStatsCardState();
}

class _ComprehensiveStatsCardState extends State<ComprehensiveStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: EdgeInsets.all(widget.isMobile ? 20 : 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(widget.isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1DB954),
                              const Color(0xFF1ed760),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: widget.isMobile ? 16 : 20,
                        ),
                      ),
                      SizedBox(width: widget.isMobile ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Music Stats',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isMobile ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Comprehensive overview',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: widget.isMobile ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: widget.isMobile ? 20 : 24),

                  // Stats grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: widget.isMobile ? 2 : 4,
                    crossAxisSpacing: widget.isMobile ? 12 : 16,
                    mainAxisSpacing: widget.isMobile ? 12 : 16,
                    childAspectRatio: widget.isMobile ? 1.2 : 1.0,
                    children: [
                      _buildStatCard(
                        'Saved Tracks',
                        '${widget.profile.totalSavedTracks}',
                        Icons.favorite,
                        const Color(0xFF1DB954),
                      ),
                      _buildStatCard(
                        'Playlists',
                        '${widget.profile.totalPlaylists}',
                        Icons.playlist_play,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Following',
                        '${widget.profile.totalFollowedArtists}',
                        Icons.person_add,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        'Saved Albums',
                        '${widget.profile.totalSavedAlbums}',
                        Icons.album,
                        Colors.orange,
                      ),
                    ],
                  ),

                  SizedBox(height: widget.isMobile ? 16 : 20),

                  // Musical diversity indicator
                  _buildMusicDiversityCard(),

                  SizedBox(height: widget.isMobile ? 16 : 20),

                  // Top genres
                  _buildTopGenresCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: widget.isMobile ? 20 : 24,
          ),
          SizedBox(height: widget.isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: widget.isMobile ? 2 : 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: widget.isMobile ? 10 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMusicDiversityCard() {
    // Calculate diversity based on different artists in top tracks
    final uniqueArtists = widget.profile.shortTermTracks
        .expand((track) => track.artists.map((a) => a.id))
        .toSet()
        .length;
    
    final totalTracks = widget.profile.shortTermTracks.length;
    final diversityScore = totalTracks > 0 
        ? (uniqueArtists / totalTracks * 100).clamp(0, 100).round()
        : 0;

    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1DB954).withOpacity(0.2),
            const Color(0xFF1ed760).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.diversity_3,
                color: const Color(0xFF1DB954),
                size: widget.isMobile ? 16 : 20,
              ),
              SizedBox(width: widget.isMobile ? 8 : 12),
              Text(
                'Music Diversity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isMobile ? 12 : 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${diversityScore}% Diverse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.isMobile ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: widget.isMobile ? 4 : 6),
                    Text(
                      '$uniqueArtists unique artists in top $totalTracks tracks',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: widget.isMobile ? 11 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: widget.isMobile ? 50 : 60,
                height: widget.isMobile ? 50 : 60,
                child: CircularProgressIndicator(
                  value: diversityScore / 100,
                  strokeWidth: widget.isMobile ? 4 : 5,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopGenresCard() {
    // Extract genres from top artists
    final genreMap = <String, int>{};
    for (final artist in widget.profile.shortTermArtists) {
      for (final genre in artist.genres) {
        genreMap[genre] = (genreMap[genre] ?? 0) + 1;
      }
    }

    final topGenres = genreMap.entries
        .where((entry) => entry.value > 1)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (topGenres.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: Colors.purple,
                size: widget.isMobile ? 16 : 20,
              ),
              SizedBox(width: widget.isMobile ? 8 : 12),
              Text(
                'Top Genres',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: widget.isMobile ? 12 : 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topGenres.take(6).map((entry) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isMobile ? 8 : 10,
                  vertical: widget.isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purple.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  entry.key.replaceAll('_', ' ').split(' ').map((word) => 
                    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
                  ).join(' '),
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: widget.isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
