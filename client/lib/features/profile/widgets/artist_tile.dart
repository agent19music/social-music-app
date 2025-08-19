import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/services/spotify_service.dart';

class ArtistTile extends StatelessWidget {
  final SpotifyArtist artist;
  final bool isMobile;
  final int? rank;

  const ArtistTile({
    super.key,
    required this.artist,
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
          color: Colors.purple.withOpacity(0.2),
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
                  color: Colors.purple,
                  fontSize: isMobile ? 12 : 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
          ],

          // Artist image
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[800],
            ),
            child: ClipOval(
              child: artist.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: artist.images.first.url,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[700],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white54,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[700],
                        child: const Icon(
                          Icons.person,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[700],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white54,
                      ),
                    ),
            ),
          ),

          SizedBox(width: isMobile ? 12 : 16),

          // Artist info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 4 : 6),

                // Genres
                if (artist.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: artist.genres.take(3).map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          genre
                              .split(' ')
                              .map((word) => word.length > 0
                                  ? word[0].toUpperCase() + word.substring(1)
                                  : word)
                              .join(' '),
                          style: TextStyle(
                            color: Colors.purple,
                            fontSize: isMobile ? 9 : 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                ],

                // Followers
                if (artist.followers != null)
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        color: Colors.white.withOpacity(0.6),
                        size: isMobile ? 12 : 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatFollowers(artist.followers!),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Popularity indicator
          if (artist.popularity != null) ...[
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
                    widthFactor: artist.popularity! / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 4 : 6),
                Text(
                  '${artist.popularity}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: isMobile ? 9 : 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
}
