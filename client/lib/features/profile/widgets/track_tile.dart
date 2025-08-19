import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/spotify_service.dart';

class TrackTile extends StatelessWidget {
  final SpotifyTrack track;
  final bool isMobile;
  final int? rank;

  const TrackTile({
    super.key,
    required this.track,
    required this.isMobile,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          if (rank != null) ...[
            Container(
              width: isMobile ? 24 : 30,
              alignment: Alignment.center,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: const Color(0xFF1DB954),
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
          ],

          // Album artwork
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[800],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: track.album.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: track.album.images.first.url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[700],
                        child: const Icon(
                          Icons.album,
                          color: Colors.white54,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[700],
                        child: const Icon(
                          Icons.album,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[700],
                      child: const Icon(
                        Icons.album,
                        color: Colors.white54,
                      ),
                    ),
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
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  track.artists.map((a) => a.name).join(', '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isMobile ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        track.album.name,
                        style: TextStyle(
                          color: const Color(0xFF1DB954),
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDuration(track.duration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Popularity indicator
          SizedBox(width: isMobile ? 8 : 12),
          Column(
            children: [
              Container(
                width: isMobile ? 32 : 40,
                height: isMobile ? 4 : 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: track.popularity / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                '${track.popularity}%',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: isMobile ? 9 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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
