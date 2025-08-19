import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'spotify_setup_screen.dart';
import 'spotify_stats_screen.dart';
import '../../../core/widgets/aux_wars_button.dart';

class MusicStatsLauncher extends ConsumerWidget {
  const MusicStatsLauncher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF1DB954),
              Color(0xFF1ed760),
              Color(0xFF121212),
              Color(0xFF191414),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Spotify icon
                Container(
                  width: isMobile ? 120 : 150,
                  height: isMobile ? 120 : 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1DB954),
                        Color(0xFF1ed760),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.show_chart,
                    color: Colors.white,
                    size: isMobile ? 60 : 80,
                  ),
                ),

                SizedBox(height: isMobile ? 40 : 50),

                // Title
                Text(
                  'Music Stats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 32 : 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: isMobile ? 12 : 16),

                // Subtitle
                Text(
                  'Discover your musical personality with Spotify insights',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 16 : 18,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: isMobile ? 40 : 60),

                // Buttons
                Column(
                  children: [
                    AuxWarsButton(
                      text: 'Setup Spotify Connection',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SpotifySetupScreen(),
                        ),
                      ),
                      icon: Icons.settings,
                      isMobile: isMobile,
                      width: double.infinity,
                      color: const Color(0xFF1DB954),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                    AuxWarsButton(
                      text: 'View Stats (Demo)',
                      onPressed: () {
                        // Show a demo version or navigate to stats
                        // For now, just show a message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Set up Spotify connection first!'),
                            backgroundColor: Color(0xFF1DB954),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icons.analytics,
                      isMobile: isMobile,
                      width: double.infinity,
                      color: Colors.purple,
                    ),
                  ],
                ),

                SizedBox(height: isMobile ? 40 : 60),

                // Features list
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1DB954).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Features:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      _buildFeatureItem(
                        '🎵',
                        'Top Tracks & Artists',
                        'See what you\'ve been loving lately',
                        isMobile,
                      ),
                      _buildFeatureItem(
                        '🎭',
                        'Mood Analysis',
                        'Discover your musical personality',
                        isMobile,
                      ),
                      _buildFeatureItem(
                        '📊',
                        'Listening Stats',
                        'Detailed insights into your music habits',
                        isMobile,
                      ),
                      _buildFeatureItem(
                        '🎨',
                        'Beautiful UI',
                        'Same design language as Aux Wars',
                        isMobile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      String emoji, String title, String description, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: isMobile ? 20 : 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
