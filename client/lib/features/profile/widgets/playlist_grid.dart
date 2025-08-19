import 'package:flutter/material.dart';
import '../../../core/services/spotify_service.dart';

class PlaylistGrid extends StatelessWidget {
  final List<SpotifyPlaylist> playlists;
  final bool isMobile;

  const PlaylistGrid({
    super.key,
    required this.playlists,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 32 : 48),
        child: Column(
          children: [
            Icon(
              Icons.playlist_play,
              color: Colors.white.withOpacity(0.3),
              size: isMobile ? 64 : 80,
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Text(
              'No playlists found',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return _buildPlaylistCard(playlist);
      },
    );
  }

  Widget _buildPlaylistCard(SpotifyPlaylist playlist) {
    return Container(
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
          // Playlist art
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: const Color(0xFF1DB954).withOpacity(0.2),
              ),
              child: playlist.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        playlist.images.first.url,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.playlist_play,
                      color: const Color(0xFF1DB954),
                      size: isMobile ? 40 : 50,
                    ),
            ),
          ),

          // Playlist info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (playlist.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      playlist.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isMobile ? 9 : 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Colors.white.withOpacity(0.5),
                        size: isMobile ? 12 : 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${playlist.trackCount}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: isMobile ? 9 : 11,
                        ),
                      ),
                      const Spacer(),
                      if (playlist.isPublic)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Public',
                            style: TextStyle(
                              color: const Color(0xFF1DB954),
                              fontSize: isMobile ? 7 : 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
