import 'package:flutter/material.dart';
import '../../../core/services/spotify_service.dart';

class CurrentlyPlayingCard extends StatefulWidget {
  final SpotifyCurrentlyPlaying currentlyPlaying;
  final SpotifyPlayerState? playerState;
  final bool isMobile;

  const CurrentlyPlayingCard({
    super.key,
    required this.currentlyPlaying,
    this.playerState,
    required this.isMobile,
  });

  @override
  State<CurrentlyPlayingCard> createState() => _CurrentlyPlayingCardState();
}

class _CurrentlyPlayingCardState extends State<CurrentlyPlayingCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: Duration(
        milliseconds: widget.currentlyPlaying.track!.duration - 
                     (widget.currentlyPlaying.progressMs ?? 0),
      ),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.currentlyPlaying.isPlaying) {
      _pulseController.repeat(reverse: true);
      _progressController.forward(
        from: (widget.currentlyPlaying.progressMs ?? 0) / widget.currentlyPlaying.track!.duration,
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.currentlyPlaying.track;
    if (track == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.currentlyPlaying.isPlaying ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: EdgeInsets.all(widget.isMobile ? 20 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1DB954).withOpacity(0.3),
                  const Color(0xFF1ed760).withOpacity(0.2),
                  Colors.black.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1DB954).withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1DB954).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
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
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1DB954).withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.currentlyPlaying.isPlaying ? Icons.play_arrow : Icons.pause,
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
                            widget.currentlyPlaying.isPlaying ? 'Now Playing' : 'Paused',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: widget.isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.playerState?.device?.name != null)
                            Text(
                              'on ${widget.playerState!.device.name}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: widget.isMobile ? 12 : 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.currentlyPlaying.isPlaying)
                      Container(
                        width: widget.isMobile ? 12 : 16,
                        height: widget.isMobile ? 12 : 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1DB954),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                SizedBox(height: widget.isMobile ? 20 : 24),

                // Track info
                Row(
                  children: [
                    // Album art
                    Container(
                      width: widget.isMobile ? 80 : 100,
                      height: widget.isMobile ? 80 : 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: track.album.images.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                track.album.images.first.url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1DB954).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.music_note,
                                color: const Color(0xFF1DB954),
                                size: widget.isMobile ? 30 : 40,
                              ),
                            ),
                    ),

                    SizedBox(width: widget.isMobile ? 16 : 20),

                    // Track details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: widget.isMobile ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: widget.isMobile ? 4 : 6),
                          Text(
                            track.artists.map((a) => a.name).join(', '),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: widget.isMobile ? 14 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: widget.isMobile ? 4 : 6),
                          Text(
                            track.album.name,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: widget.isMobile ? 12 : 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          SizedBox(height: widget.isMobile ? 12 : 16),
                          
                          // Track features
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildFeaturePill('${track.popularity}% Popular', Colors.orange),
                              if (track.album.releaseDate.isNotEmpty)
                                _buildFeaturePill(
                                  track.album.releaseDate.split('-').first,
                                  Colors.blue,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: widget.isMobile ? 16 : 20),

                // Progress bar
                _buildProgressBar(),

                SizedBox(height: widget.isMobile ? 12 : 16),

                // Controls (if available)
                if (widget.playerState != null)
                  _buildPlayerControls(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturePill(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 6 : 8,
        vertical: widget.isMobile ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: widget.isMobile ? 8 : 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progressMs = widget.currentlyPlaying.progressMs ?? 0;
    final progress = progressMs / widget.currentlyPlaying.track!.duration;
    final currentTime = _formatDuration(progressMs);
    final totalTime = _formatDuration(widget.currentlyPlaying.track!.duration);

    return Column(
      children: [
        Row(
          children: [
            Text(
              currentTime,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: widget.isMobile ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 12 : 16),
                height: widget.isMobile ? 4 : 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(widget.isMobile ? 2 : 3),
                ),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widget.currentlyPlaying.isPlaying 
                          ? _progressController.value 
                          : progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1DB954),
                              const Color(0xFF1ed760),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(widget.isMobile ? 2 : 3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1DB954).withOpacity(0.4),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(
              totalTime,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: widget.isMobile ? 10 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          Icons.shuffle,
          widget.playerState!.shuffleState,
          'Shuffle',
        ),
        SizedBox(width: widget.isMobile ? 16 : 20),
        _buildControlButton(
          Icons.skip_previous,
          true,
          'Previous',
        ),
        SizedBox(width: widget.isMobile ? 20 : 24),
        Container(
          width: widget.isMobile ? 50 : 60,
          height: widget.isMobile ? 50 : 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1DB954),
                const Color(0xFF1ed760),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1DB954).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            widget.currentlyPlaying.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: widget.isMobile ? 24 : 28,
          ),
        ),
        SizedBox(width: widget.isMobile ? 20 : 24),
        _buildControlButton(
          Icons.skip_next,
          true,
          'Next',
        ),
        SizedBox(width: widget.isMobile ? 16 : 20),
        _buildControlButton(
          widget.playerState!.repeatState == 'track' 
              ? Icons.repeat_one 
              : Icons.repeat,
          widget.playerState!.repeatState != 'off',
          'Repeat',
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, bool isActive, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: widget.isMobile ? 36 : 44,
        height: widget.isMobile ? 36 : 44,
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF1DB954).withOpacity(0.3) 
              : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive 
                ? const Color(0xFF1DB954).withOpacity(0.5) 
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF1DB954) : Colors.white.withOpacity(0.7),
          size: widget.isMobile ? 16 : 20,
        ),
      ),
    );
  }

  String _formatDuration(int durationMs) {
    final duration = Duration(milliseconds: durationMs);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
