import 'package:flutter/material.dart';
import '../../../core/services/spotify_service.dart';

class SavedContentTabs extends StatefulWidget {
  final SpotifyProfileData profile;
  final bool isMobile;

  const SavedContentTabs({
    super.key,
    required this.profile,
    required this.isMobile,
  });

  @override
  State<SavedContentTabs> createState() => _SavedContentTabsState();
}

class _SavedContentTabsState extends State<SavedContentTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 32),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
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
              fontSize: widget.isMobile ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: widget.isMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1DB954),
                  const Color(0xFF1ed760),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorPadding: EdgeInsets.all(widget.isMobile ? 4 : 6),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(text: 'Tracks'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),

        SizedBox(height: widget.isMobile ? 12 : 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTracksTab(),
              _buildAlbumsTab(),
              _buildArtistsTab(),
              _buildPlaylistsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTracksTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Saved Tracks (${widget.profile.totalSavedTracks})'),
          const SizedBox(height: 12),
          ...widget.profile.savedTracks.map((track) {
            return _buildTrackTile(track);
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildAlbumsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Saved Albums (${widget.profile.totalSavedAlbums})'),
          const SizedBox(height: 12),
          if (widget.profile.savedAlbums.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.isMobile ? 2 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: widget.profile.savedAlbums.length,
              itemBuilder: (context, index) {
                final album = widget.profile.savedAlbums[index];
                return _buildAlbumCard(album);
              },
            ),
          ] else ...[
            _buildEmptyState('No saved albums yet', Icons.album),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildArtistsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Following (${widget.profile.totalFollowedArtists})'),
          const SizedBox(height: 12),
          if (widget.profile.followedArtists.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.isMobile ? 2 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: widget.profile.followedArtists.length,
              itemBuilder: (context, index) {
                final artist = widget.profile.followedArtists[index];
                return _buildArtistCard(artist);
              },
            ),
          ] else ...[
            _buildEmptyState('No followed artists yet', Icons.person),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: widget.isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Your Playlists (${widget.profile.totalPlaylists})'),
          const SizedBox(height: 12),
          if (widget.profile.playlists.isNotEmpty) ...[
            ...widget.profile.playlists.map((playlist) {
              return _buildPlaylistTile(playlist);
            }),
          ] else ...[
            _buildEmptyState('No playlists created yet', Icons.playlist_play),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: widget.isMobile ? 16 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTrackTile(SpotifyTrack track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
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
            width: widget.isMobile ? 50 : 60,
            height: widget.isMobile ? 50 : 60,
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
                    size: widget.isMobile ? 20 : 24,
                  ),
          ),

          SizedBox(width: widget.isMobile ? 12 : 16),

          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  track.artists.map((a) => a.name).join(', '),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: widget.isMobile ? 12 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  track.album.name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: widget.isMobile ? 10 : 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Popularity indicator
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 6 : 8,
              vertical: widget.isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: _getPopularityColor(track.popularity).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getPopularityColor(track.popularity).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              '${track.popularity}%',
              style: TextStyle(
                color: _getPopularityColor(track.popularity),
                fontSize: widget.isMobile ? 9 : 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(SpotifyAlbum album) {
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
          // Album art
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: const Color(0xFF1DB954).withOpacity(0.2),
              ),
              child: album.images.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        album.images.first.url,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.album,
                      color: const Color(0xFF1DB954),
                      size: widget.isMobile ? 40 : 50,
                    ),
            ),
          ),

          // Album info
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(widget.isMobile ? 8 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Artist Name',  // Need to get from track or separate API call
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: widget.isMobile ? 10 : 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Colors.white.withOpacity(0.5),
                        size: widget.isMobile ? 12 : 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${album.totalTracks} tracks',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: widget.isMobile ? 9 : 11,
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

  Widget _buildArtistCard(SpotifyArtist artist) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Artist image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1DB954).withOpacity(0.2),
                border: Border.all(
                  color: const Color(0xFF1DB954).withOpacity(0.3),
                  width: 2,
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
                      size: widget.isMobile ? 30 : 40,
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Artist info
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  artist.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isMobile ? 12 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isMobile ? 6 : 8,
                    vertical: widget.isMobile ? 2 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getPopularityColor(artist.popularity ?? 0).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getPopularityColor(artist.popularity ?? 0).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${artist.popularity}% Popular',
                    style: TextStyle(
                      color: _getPopularityColor(artist.popularity ?? 0),
                      fontSize: widget.isMobile ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistTile(SpotifyPlaylist playlist) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
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
          // Playlist art
          Container(
            width: widget.isMobile ? 50 : 60,
            height: widget.isMobile ? 50 : 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF1DB954).withOpacity(0.2),
            ),
            child: playlist.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      playlist.images.first.url,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.playlist_play,
                    color: const Color(0xFF1DB954),
                    size: widget.isMobile ? 20 : 24,
                  ),
          ),

          SizedBox(width: widget.isMobile ? 12 : 16),

          // Playlist info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (playlist.description.isNotEmpty) ...[
                  Text(
                    playlist.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: widget.isMobile ? 11 : 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      color: Colors.white.withOpacity(0.5),
                      size: widget.isMobile ? 12 : 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${playlist.trackCount} tracks',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: widget.isMobile ? 10 : 12,
                      ),
                    ),
                    if (playlist.isPublic) ...[
                      SizedBox(width: widget.isMobile ? 8 : 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Public',
                          style: TextStyle(
                            color: const Color(0xFF1DB954),
                            fontSize: widget.isMobile ? 8 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Followers count - remove this section as SpotifyPlaylist doesn't have followers
          // if (playlist.followers.total > 0)
          //   Container(
          //     padding: EdgeInsets.symmetric(
          //       horizontal: widget.isMobile ? 6 : 8,
          //       vertical: widget.isMobile ? 3 : 4,
          //     ),
          //     decoration: BoxDecoration(
          //       color: Colors.purple.withOpacity(0.2),
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(
          //         color: Colors.purple.withOpacity(0.5),
          //         width: 1,
          //       ),
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Icon(
          //           Icons.people,
          //           color: Colors.purple,
          //           size: widget.isMobile ? 10 : 12,
          //         ),
          //         const SizedBox(width: 2),
          //         Text(
          //           '${playlist.followers.total}',
          //           style: TextStyle(
          //             color: Colors.purple,
          //             fontSize: widget.isMobile ? 9 : 11,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 32 : 48),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white.withOpacity(0.3),
            size: widget.isMobile ? 64 : 80,
          ),
          SizedBox(height: widget.isMobile ? 16 : 20),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: widget.isMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPopularityColor(int popularity) {
    if (popularity >= 80) return Colors.green;
    if (popularity >= 60) return Colors.orange;
    if (popularity >= 40) return Colors.yellow;
    return Colors.red;
  }
}
