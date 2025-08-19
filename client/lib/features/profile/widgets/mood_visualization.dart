import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/providers/spotify_providers.dart';

class MoodVisualization extends StatefulWidget {
  final SpotifyStats stats;
  final bool isMobile;

  const MoodVisualization({
    super.key,
    required this.stats,
    required this.isMobile,
  });

  @override
  State<MoodVisualization> createState() => _MoodVisualizationState();
}

class _MoodVisualizationState extends State<MoodVisualization>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.stats.moodProfile;
    final size = widget.isMobile ? 200.0 : 250.0;

    return Column(
      children: [
        // Mood circle visualization
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _rotateController]),
          builder: (context, child) {
            return Container(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rings
                  for (int i = 0; i < 3; i++)
                    Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi +
                          (i * math.pi / 3),
                      child: Container(
                        width: size - (i * 30),
                        height: size - (i * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getMoodColor(mood.dominantMood).withOpacity(
                                0.3 -
                                    (i * 0.1) +
                                    (_pulseController.value * 0.2)),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                  // Mood indicators
                  _buildMoodIndicator(
                      'Happy', mood.happy, Colors.yellow, 0, size),
                  _buildMoodIndicator('Energetic', mood.energetic, Colors.red,
                      math.pi / 2, size),
                  _buildMoodIndicator('Danceable', mood.danceable,
                      Colors.purple, math.pi, size),
                  _buildMoodIndicator('Acoustic', mood.acoustic, Colors.brown,
                      3 * math.pi / 2, size),

                  // Center circle
                  Container(
                    width: size * 0.3,
                    height: size * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _getMoodColor(mood.dominantMood).withOpacity(0.8),
                          _getMoodColor(mood.dominantMood).withOpacity(0.4),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _getMoodColor(mood.dominantMood).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _getMoodIcon(mood.dominantMood),
                      color: Colors.white,
                      size: widget.isMobile ? 30 : 40,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        // Mood stats
        Text(
          'Your dominant mood: ${mood.dominantMood}',
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 24),

        // Mood breakdown
        _buildMoodBreakdown(mood),

        const SizedBox(height: 24),

        // Audio feature stats
        _buildAudioFeatureStats(),
      ],
    );
  }

  Widget _buildMoodIndicator(
      String label, double value, Color color, double angle, double size) {
    final radius = size * 0.35;
    final indicatorSize = widget.isMobile ? 16.0 : 20.0;

    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle);

    return Transform.translate(
      offset: Offset(x, y),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: indicatorSize,
            height: indicatorSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(value),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodBreakdown(MoodProfile mood) {
    final moods = [
      ('Happy', mood.happy, Colors.yellow),
      ('Energetic', mood.energetic, Colors.red),
      ('Danceable', mood.danceable, Colors.purple),
      ('Acoustic', mood.acoustic, Colors.brown),
    ];

    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Breakdown',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...moods.map((mood) => _buildMoodBar(mood.$1, mood.$2, mood.$3)),
        ],
      ),
    );
  }

  Widget _buildMoodBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: widget.isMobile ? 70 : 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: widget.isMobile ? 12 : 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: widget.isMobile ? 6 : 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioFeatureStats() {
    if (widget.stats.audioFeatures.isEmpty) {
      return const SizedBox.shrink();
    }

    final avgTempo =
        widget.stats.audioFeatures.map((f) => f.tempo).reduce((a, b) => a + b) /
            widget.stats.audioFeatures.length;

    final avgLoudness = widget.stats.audioFeatures
            .map((f) => f.loudness)
            .reduce((a, b) => a + b) /
        widget.stats.audioFeatures.length;

    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audio Analysis',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Avg Tempo',
                  '${avgTempo.toInt()} BPM',
                  Icons.speed,
                  const Color(0xFF1DB954),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Avg Loudness',
                  '${avgLoudness.toStringAsFixed(1)} dB',
                  Icons.volume_up,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Tracks Analyzed',
                  widget.stats.audioFeatures.length.toString(),
                  Icons.analytics,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Variety Score',
                  '${widget.stats.varietyScore.toInt()}%',
                  Icons.shuffle,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
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
              fontSize: widget.isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: widget.isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.yellow;
      case 'energetic':
        return Colors.red;
      case 'danceable':
        return Colors.purple;
      case 'acoustic':
        return Colors.brown;
      default:
        return const Color(0xFF1DB954);
    }
  }

  IconData _getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'energetic':
        return Icons.flash_on;
      case 'danceable':
        return Icons.music_note;
      case 'acoustic':
        return Icons.piano;
      default:
        return Icons.music_note;
    }
  }
}
