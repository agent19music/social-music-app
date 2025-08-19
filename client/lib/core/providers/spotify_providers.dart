import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/spotify_service.dart';

// Spotify Service Provider
final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  return SpotifyService();
});

// Current User Provider
final spotifyCurrentUserProvider = FutureProvider<SpotifyUser?>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getCurrentUser();
});

// Recently Played Tracks Provider
final spotifyRecentlyPlayedProvider =
    FutureProvider<List<SpotifyTrack>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getRecentlyPlayedTracks(limit: 20);
});

// Top Tracks Provider
final spotifyTopTracksProvider =
    FutureProvider.family<List<SpotifyTrack>, String>((ref, timeRange) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getTopTracks(timeRange: timeRange, limit: 20);
});

// Top Artists Provider
final spotifyTopArtistsProvider =
    FutureProvider.family<List<SpotifyArtist>, String>((ref, timeRange) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getTopArtists(timeRange: timeRange, limit: 20);
});

// Currently Playing Provider
final spotifyCurrentlyPlayingProvider =
    FutureProvider<SpotifyCurrentlyPlaying?>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getCurrentlyPlaying();
});

// User Playlists Provider
final spotifyUserPlaylistsProvider =
    FutureProvider<List<SpotifyPlaylist>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getUserPlaylists(limit: 50);
});

// Stats Provider that combines multiple data sources
final spotifyStatsProvider = FutureProvider<SpotifyStats>((ref) async {
  final service = ref.read(spotifyServiceProvider);

  // Fetch all data in parallel
  final results = await Future.wait([
    service.getTopTracks(timeRange: 'short_term', limit: 50),
    service.getTopArtists(timeRange: 'short_term', limit: 20),
    service.getTopTracks(timeRange: 'medium_term', limit: 50),
    service.getTopArtists(timeRange: 'medium_term', limit: 20),
    service.getRecentlyPlayedTracks(limit: 50),
    service.getUserPlaylists(limit: 20),
  ]);

  final shortTermTracks = results[0] as List<SpotifyTrack>;
  final shortTermArtists = results[1] as List<SpotifyArtist>;
  final mediumTermTracks = results[2] as List<SpotifyTrack>;
  final mediumTermArtists = results[3] as List<SpotifyArtist>;
  final recentTracks = results[4] as List<SpotifyTrack>;
  final playlists = results[5] as List<SpotifyPlaylist>;

  // Get audio features for analysis
  final trackIds = [...shortTermTracks, ...mediumTermTracks]
      .take(50)
      .map((t) => t.id)
      .toSet()
      .toList();

  final audioFeatures = await service.getMultipleAudioFeatures(trackIds);

  return SpotifyStats(
    shortTermTracks: shortTermTracks,
    shortTermArtists: shortTermArtists,
    mediumTermTracks: mediumTermTracks,
    mediumTermArtists: mediumTermArtists,
    recentTracks: recentTracks,
    playlists: playlists,
    audioFeatures: audioFeatures,
  );
});

// Combined stats data model
class SpotifyStats {
  final List<SpotifyTrack> shortTermTracks;
  final List<SpotifyArtist> shortTermArtists;
  final List<SpotifyTrack> mediumTermTracks;
  final List<SpotifyArtist> mediumTermArtists;
  final List<SpotifyTrack> recentTracks;
  final List<SpotifyPlaylist> playlists;
  final List<SpotifyAudioFeatures> audioFeatures;

  SpotifyStats({
    required this.shortTermTracks,
    required this.shortTermArtists,
    required this.mediumTermTracks,
    required this.mediumTermArtists,
    required this.recentTracks,
    required this.playlists,
    required this.audioFeatures,
  });

  // Calculated stats
  int get totalTracksAnalyzed =>
      shortTermTracks.length + mediumTermTracks.length;

  int get totalArtists => {
        ...shortTermArtists.map((a) => a.id),
        ...mediumTermArtists.map((a) => a.id),
      }.length;

  double get averageDanceability => audioFeatures.isEmpty
      ? 0.0
      : audioFeatures.map((f) => f.danceability).reduce((a, b) => a + b) /
          audioFeatures.length;

  double get averageEnergy => audioFeatures.isEmpty
      ? 0.0
      : audioFeatures.map((f) => f.energy).reduce((a, b) => a + b) /
          audioFeatures.length;

  double get averageValence => audioFeatures.isEmpty
      ? 0.0
      : audioFeatures.map((f) => f.valence).reduce((a, b) => a + b) /
          audioFeatures.length;

  double get averageAcousticness => audioFeatures.isEmpty
      ? 0.0
      : audioFeatures.map((f) => f.acousticness).reduce((a, b) => a + b) /
          audioFeatures.length;

  // Get most common genres
  List<String> get topGenres {
    final genreCount = <String, int>{};
    for (final artist in [...shortTermArtists, ...mediumTermArtists]) {
      for (final genre in artist.genres) {
        genreCount[genre] = (genreCount[genre] ?? 0) + 1;
      }
    }

    final sorted = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(10).map((e) => e.key).toList();
  }

  // Get listening variety score (0-100)
  double get varietyScore {
    if (totalArtists == 0 || totalTracksAnalyzed == 0) return 0.0;
    return (totalArtists / totalTracksAnalyzed * 100).clamp(0.0, 100.0);
  }

  // Get mood profile
  MoodProfile get moodProfile {
    if (audioFeatures.isEmpty) {
      return MoodProfile(
        happy: 0.0,
        energetic: 0.0,
        danceable: 0.0,
        acoustic: 0.0,
      );
    }

    return MoodProfile(
      happy: averageValence,
      energetic: averageEnergy,
      danceable: averageDanceability,
      acoustic: averageAcousticness,
    );
  }
}

class MoodProfile {
  final double happy;
  final double energetic;
  final double danceable;
  final double acoustic;

  MoodProfile({
    required this.happy,
    required this.energetic,
    required this.danceable,
    required this.acoustic,
  });

  String get dominantMood {
    final moods = [
      ('Happy', happy),
      ('Energetic', energetic),
      ('Danceable', danceable),
      ('Acoustic', acoustic),
    ];

    moods.sort((a, b) => b.$2.compareTo(a.$2));
    return moods.first.$1;
  }
}

// Additional comprehensive providers

// Comprehensive Profile Provider - fetches ALL possible data
final spotifyComprehensiveProfileProvider = FutureProvider<SpotifyProfileData>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getComprehensiveProfile();
});

// Saved Tracks Provider
final spotifySavedTracksProvider = FutureProvider<List<SpotifyTrack>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getSavedTracks(limit: 50);
});

// Saved Albums Provider
final spotifySavedAlbumsProvider = FutureProvider<List<SpotifyAlbum>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getSavedAlbums(limit: 50);
});

// Followed Artists Provider
final spotifyFollowedArtistsProvider = FutureProvider<List<SpotifyArtist>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getFollowedArtists(limit: 50);
});

// Player State Provider
final spotifyPlayerStateProvider = FutureProvider<SpotifyPlayerState?>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getPlayerState();
});

// Available Devices Provider
final spotifyAvailableDevicesProvider = FutureProvider<List<SpotifyDevice>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getAvailableDevices();
});

// Featured Playlists Provider
final spotifyFeaturedPlaylistsProvider = FutureProvider<List<SpotifyPlaylist>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getFeaturedPlaylists(limit: 20);
});

// New Releases Provider
final spotifyNewReleasesProvider = FutureProvider<List<SpotifyAlbum>>((ref) async {
  final service = ref.read(spotifyServiceProvider);
  return await service.getNewReleases(limit: 20);
});
