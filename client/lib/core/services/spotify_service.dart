import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SpotifyService {
  static const String _baseUrl = 'https://api.spotify.com/v1';
  late final Dio _dio;

  String? _accessToken;
  String? _refreshToken;
  String? _clientId;
  String? _clientSecret;

  SpotifyService() {
    _dio = Dio();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshAccessToken();
          if (refreshed) {
            // Retry the request
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $_accessToken';
            try {
              final response = await _dio.fetch(opts);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, let the original error through
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  void initialize({
    required String clientId,
    required String clientSecret,
    String? refreshToken,
    String? accessToken,
  }) {
    _clientId = clientId;
    _clientSecret = clientSecret;
    _refreshToken = refreshToken;
    _accessToken = accessToken;
  }

  // OAuth methods for getting user authorization
  String getAuthorizationUrl({String redirectUri = 'http://localhost:8888/callback'}) {
    if (_clientId == null) throw Exception('Client ID not initialized');
    
    final scopes = [
      'user-read-private',
      'user-read-email', 
      'user-top-read',
      'user-read-recently-played',
      'user-library-read',
      'playlist-read-private',
      'user-read-playback-state',
      'user-read-currently-playing',
      'user-follow-read',
      'user-read-playback-position'
    ].join(' ');

    final params = {
      'client_id': _clientId!,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': scopes,
      'show_dialog': 'true',
    };

    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return 'https://accounts.spotify.com/authorize?$query';
  }

  Future<bool> exchangeCodeForTokens(String code, {String redirectUri = 'http://localhost:8888/callback'}) async {
    if (_clientId == null || _clientSecret == null) return false;

    try {
      final credentials = base64.encode(utf8.encode('$_clientId:$_clientSecret'));
      final response = await Dio().post(
        'https://accounts.spotify.com/api/token',
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
        },
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];
        _refreshToken = response.data['refresh_token'];
        return true;
      }
    } catch (e) {
      debugPrint('Error exchanging code for tokens: $e');
    }
    return false;
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null || _clientId == null || _clientSecret == null) {
      return false;
    }

    try {
      final credentials =
          base64.encode(utf8.encode('$_clientId:$_clientSecret'));
      final response = await Dio().post(
        'https://accounts.spotify.com/api/token',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': _refreshToken,
        },
        options: Options(
          headers: {
            'Authorization': 'Basic $credentials',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        _accessToken = response.data['access_token'];
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing Spotify token: $e');
    }
    return false;
  }

  // User Profile
  Future<SpotifyUser?> getCurrentUser() async {
    try {
      final response = await _dio.get('$_baseUrl/me');
      if (response.statusCode == 200) {
        return SpotifyUser.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
    return null;
  }

  // Recently Played Tracks
  Future<List<SpotifyTrack>> getRecentlyPlayedTracks({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me/player/recently-played',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items
            .map((item) => SpotifyTrack.fromJson(item['track']))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching recently played: $e');
    }
    return [];
  }

  // Top Tracks
  Future<List<SpotifyTrack>> getTopTracks({
    int limit = 20,
    String timeRange = 'medium_term', // short_term, medium_term, long_term
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me/top/tracks',
        queryParameters: {
          'limit': limit,
          'time_range': timeRange,
        },
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((item) => SpotifyTrack.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching top tracks: $e');
    }
    return [];
  }

  // Top Artists
  Future<List<SpotifyArtist>> getTopArtists({
    int limit = 20,
    String timeRange = 'medium_term',
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me/top/artists',
        queryParameters: {
          'limit': limit,
          'time_range': timeRange,
        },
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((item) => SpotifyArtist.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching top artists: $e');
    }
    return [];
  }

  // Currently Playing
  Future<SpotifyCurrentlyPlaying?> getCurrentlyPlaying() async {
    try {
      final response = await _dio.get('$_baseUrl/me/player/currently-playing');
      if (response.statusCode == 200 && response.data != null) {
        return SpotifyCurrentlyPlaying.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching currently playing: $e');
    }
    return null;
  }

  // User's Playlists
  Future<List<SpotifyPlaylist>> getUserPlaylists({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me/playlists',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((item) => SpotifyPlaylist.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching playlists: $e');
    }
    return [];
  }

  // Audio Features for tracks (useful for stats)
  Future<SpotifyAudioFeatures?> getAudioFeatures(String trackId) async {
    try {
      final response = await _dio.get('$_baseUrl/audio-features/$trackId');
      if (response.statusCode == 200) {
        return SpotifyAudioFeatures.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching audio features: $e');
    }
    return null;
  }

  // Get multiple audio features at once
  Future<List<SpotifyAudioFeatures>> getMultipleAudioFeatures(
      List<String> trackIds) async {
    try {
      final ids = trackIds.join(',');
      final response = await _dio.get(
        '$_baseUrl/audio-features',
        queryParameters: {'ids': ids},
      );
      if (response.statusCode == 200) {
        final features = response.data['audio_features'] as List;
        return features
            .where((f) => f != null)
            .map((f) => SpotifyAudioFeatures.fromJson(f))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching multiple audio features: $e');
    }
    return [];
  }

  // Additional comprehensive API methods for maximum data

  // Saved Albums
  Future<List<SpotifyAlbum>> getSavedAlbums({int limit = 50}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me/albums',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((item) => SpotifyAlbum.fromJson(item['album'])).toList();
      }
    } catch (e) {
      debugPrint('Error fetching saved albums: $e');
    }
    return [];
  }

  // Saved Tracks
  Future<List<SpotifyTrack>> getSavedTracks({int limit = 50}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me/tracks',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((item) => SpotifyTrack.fromJson(item['track'])).toList();
      }
    } catch (e) {
      debugPrint('Error fetching saved tracks: $e');
    }
    return [];
  }

  // Followed Artists
  Future<List<SpotifyArtist>> getFollowedArtists({int limit = 50}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/me/following',
        queryParameters: {
          'type': 'artist',
          'limit': limit,
        },
      );
      if (response.statusCode == 200) {
        final items = response.data['artists']['items'] as List;
        return items.map((item) => SpotifyArtist.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching followed artists: $e');
    }
    return [];
  }

  // Player State
  Future<SpotifyPlayerState?> getPlayerState() async {
    try {
      final response = await _dio.get('$_baseUrl/me/player');
      if (response.statusCode == 200 && response.data != null) {
        return SpotifyPlayerState.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error fetching player state: $e');
    }
    return null;
  }

  // Available Devices
  Future<List<SpotifyDevice>> getAvailableDevices() async {
    try {
      final response = await _dio.get('$_baseUrl/me/player/devices');
      if (response.statusCode == 200) {
        final devices = response.data['devices'] as List;
        return devices.map((device) => SpotifyDevice.fromJson(device)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching devices: $e');
    }
    return [];
  }

  // Featured Playlists (for discovery)
  Future<List<SpotifyPlaylist>> getFeaturedPlaylists({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/browse/featured-playlists',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final items = response.data['playlists']['items'] as List;
        return items.map((item) => SpotifyPlaylist.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching featured playlists: $e');
    }
    return [];
  }

  // New Releases
  Future<List<SpotifyAlbum>> getNewReleases({int limit = 20}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/browse/new-releases',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final items = response.data['albums']['items'] as List;
        return items.map((item) => SpotifyAlbum.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching new releases: $e');
    }
    return [];
  }

  // Playlist tracks
  Future<List<SpotifyTrack>> getPlaylistTracks(String playlistId, {int limit = 100}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/playlists/$playlistId/tracks',
        queryParameters: {'limit': limit},
      );
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items
            .where((item) => item['track'] != null && item['track']['type'] == 'track')
            .map((item) => SpotifyTrack.fromJson(item['track']))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching playlist tracks: $e');
    }
    return [];
  }

  // Search functionality
  Future<SpotifySearchResults> search(String query, {
    List<String> types = const ['track', 'artist', 'album', 'playlist'],
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'q': query,
          'type': types.join(','),
          'limit': limit,
        },
      );
      if (response.statusCode == 200) {
        return SpotifySearchResults.fromJson(response.data);
      }
    } catch (e) {
      debugPrint('Error searching: $e');
    }
    return SpotifySearchResults.empty();
  }

  // Get comprehensive user profile data
  Future<SpotifyProfileData> getComprehensiveProfile() async {
    try {
      final user = await getCurrentUser();
      final shortTermTracks = await getTopTracks(limit: 50, timeRange: 'short_term');
      final mediumTermTracks = await getTopTracks(limit: 50, timeRange: 'medium_term');
      final longTermTracks = await getTopTracks(limit: 50, timeRange: 'long_term');
      final shortTermArtists = await getTopArtists(limit: 50, timeRange: 'short_term');
      final mediumTermArtists = await getTopArtists(limit: 50, timeRange: 'medium_term');
      final longTermArtists = await getTopArtists(limit: 50, timeRange: 'long_term');
      final recentTracks = await getRecentlyPlayedTracks(limit: 50);
      final playlists = await getUserPlaylists(limit: 50);
      final savedTracks = await getSavedTracks(limit: 50);
      final savedAlbums = await getSavedAlbums(limit: 50);
      final followedArtists = await getFollowedArtists(limit: 50);
      final currentlyPlaying = await getCurrentlyPlaying();
      final playerState = await getPlayerState();
      final devices = await getAvailableDevices();

      return SpotifyProfileData(
        user: user,
        shortTermTracks: shortTermTracks,
        mediumTermTracks: mediumTermTracks,
        longTermTracks: longTermTracks,
        shortTermArtists: shortTermArtists,
        mediumTermArtists: mediumTermArtists,
        longTermArtists: longTermArtists,
        recentTracks: recentTracks,
        playlists: playlists,
        savedTracks: savedTracks,
        savedAlbums: savedAlbums,
        followedArtists: followedArtists,
        currentlyPlaying: currentlyPlaying,
        playerState: playerState,
        devices: devices,
      );
    } catch (e) {
      debugPrint('Error fetching comprehensive profile: $e');
      throw e;
    }
  }
}

// Data Models
class SpotifyUser {
  final String id;
  final String displayName;
  final String? email;
  final int followers;
  final List<SpotifyImage> images;
  final String country;
  final String product; // free, premium

  SpotifyUser({
    required this.id,
    required this.displayName,
    this.email,
    required this.followers,
    required this.images,
    required this.country,
    required this.product,
  });

  factory SpotifyUser.fromJson(Map<String, dynamic> json) {
    return SpotifyUser(
      id: json['id'],
      displayName: json['display_name'] ?? '',
      email: json['email'],
      followers: json['followers']?['total'] ?? 0,
      images: (json['images'] as List? ?? [])
          .map((img) => SpotifyImage.fromJson(img))
          .toList(),
      country: json['country'] ?? '',
      product: json['product'] ?? 'free',
    );
  }
}

class SpotifyTrack {
  final String id;
  final String name;
  final List<SpotifyArtist> artists;
  final SpotifyAlbum album;
  final int duration;
  final int popularity;
  final String? previewUrl;

  SpotifyTrack({
    required this.id,
    required this.name,
    required this.artists,
    required this.album,
    required this.duration,
    required this.popularity,
    this.previewUrl,
  });

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) {
    return SpotifyTrack(
      id: json['id'],
      name: json['name'],
      artists: (json['artists'] as List)
          .map((artist) => SpotifyArtist.fromJson(artist))
          .toList(),
      album: SpotifyAlbum.fromJson(json['album']),
      duration: json['duration_ms'],
      popularity: json['popularity'] ?? 0,
      previewUrl: json['preview_url'],
    );
  }
}

class SpotifyArtist {
  final String id;
  final String name;
  final List<SpotifyImage> images;
  final int? followers;
  final int? popularity;
  final List<String> genres;

  SpotifyArtist({
    required this.id,
    required this.name,
    required this.images,
    this.followers,
    this.popularity,
    required this.genres,
  });

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) {
    return SpotifyArtist(
      id: json['id'],
      name: json['name'],
      images: (json['images'] as List? ?? [])
          .map((img) => SpotifyImage.fromJson(img))
          .toList(),
      followers: json['followers']?['total'],
      popularity: json['popularity'],
      genres: List<String>.from(json['genres'] ?? []),
    );
  }
}

class SpotifyAlbum {
  final String id;
  final String name;
  final List<SpotifyImage> images;
  final String releaseDate;
  final int totalTracks;

  SpotifyAlbum({
    required this.id,
    required this.name,
    required this.images,
    required this.releaseDate,
    required this.totalTracks,
  });

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) {
    return SpotifyAlbum(
      id: json['id'],
      name: json['name'],
      images: (json['images'] as List? ?? [])
          .map((img) => SpotifyImage.fromJson(img))
          .toList(),
      releaseDate: json['release_date'] ?? '',
      totalTracks: json['total_tracks'] ?? 0,
    );
  }
}

class SpotifyImage {
  final String url;
  final int? width;
  final int? height;

  SpotifyImage({
    required this.url,
    this.width,
    this.height,
  });

  factory SpotifyImage.fromJson(Map<String, dynamic> json) {
    return SpotifyImage(
      url: json['url'],
      width: json['width'],
      height: json['height'],
    );
  }
}

class SpotifyCurrentlyPlaying {
  final SpotifyTrack? track;
  final bool isPlaying;
  final int? progressMs;

  SpotifyCurrentlyPlaying({
    this.track,
    required this.isPlaying,
    this.progressMs,
  });

  factory SpotifyCurrentlyPlaying.fromJson(Map<String, dynamic> json) {
    return SpotifyCurrentlyPlaying(
      track: json['item'] != null ? SpotifyTrack.fromJson(json['item']) : null,
      isPlaying: json['is_playing'] ?? false,
      progressMs: json['progress_ms'],
    );
  }
}

class SpotifyPlaylist {
  final String id;
  final String name;
  final String description;
  final List<SpotifyImage> images;
  final int trackCount;
  final bool isPublic;

  SpotifyPlaylist({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.trackCount,
    required this.isPublic,
  });

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) {
    return SpotifyPlaylist(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      images: (json['images'] as List? ?? [])
          .map((img) => SpotifyImage.fromJson(img))
          .toList(),
      trackCount: json['tracks']?['total'] ?? 0,
      isPublic: json['public'] ?? false,
    );
  }
}

class SpotifyAudioFeatures {
  final String id;
  final double danceability;
  final double energy;
  final double valence; // positivity
  final double acousticness;
  final double instrumentalness;
  final double liveness;
  final double speechiness;
  final double tempo;
  final int key;
  final int mode; // 0 = minor, 1 = major
  final int timeSignature;
  final double loudness;

  SpotifyAudioFeatures({
    required this.id,
    required this.danceability,
    required this.energy,
    required this.valence,
    required this.acousticness,
    required this.instrumentalness,
    required this.liveness,
    required this.speechiness,
    required this.tempo,
    required this.key,
    required this.mode,
    required this.timeSignature,
    required this.loudness,
  });

  factory SpotifyAudioFeatures.fromJson(Map<String, dynamic> json) {
    return SpotifyAudioFeatures(
      id: json['id'],
      danceability: (json['danceability'] as num).toDouble(),
      energy: (json['energy'] as num).toDouble(),
      valence: (json['valence'] as num).toDouble(),
      acousticness: (json['acousticness'] as num).toDouble(),
      instrumentalness: (json['instrumentalness'] as num).toDouble(),
      liveness: (json['liveness'] as num).toDouble(),
      speechiness: (json['speechiness'] as num).toDouble(),
      tempo: (json['tempo'] as num).toDouble(),
      key: json['key'],
      mode: json['mode'],
      timeSignature: json['time_signature'],
      loudness: (json['loudness'] as num).toDouble(),
    );
  }
}

// Additional data models for comprehensive profile

class SpotifyPlayerState {
  final SpotifyDevice device;
  final bool shuffleState;
  final String repeatState; // off, track, context
  final int? progressMs;
  final bool isPlaying;
  final SpotifyTrack? item;

  SpotifyPlayerState({
    required this.device,
    required this.shuffleState,
    required this.repeatState,
    this.progressMs,
    required this.isPlaying,
    this.item,
  });

  factory SpotifyPlayerState.fromJson(Map<String, dynamic> json) {
    return SpotifyPlayerState(
      device: SpotifyDevice.fromJson(json['device']),
      shuffleState: json['shuffle_state'] ?? false,
      repeatState: json['repeat_state'] ?? 'off',
      progressMs: json['progress_ms'],
      isPlaying: json['is_playing'] ?? false,
      item: json['item'] != null ? SpotifyTrack.fromJson(json['item']) : null,
    );
  }
}

class SpotifyDevice {
  final String id;
  final bool isActive;
  final bool isPrivateSession;
  final bool isRestricted;
  final String name;
  final String type;
  final int? volumePercent;

  SpotifyDevice({
    required this.id,
    required this.isActive,
    required this.isPrivateSession,
    required this.isRestricted,
    required this.name,
    required this.type,
    this.volumePercent,
  });

  factory SpotifyDevice.fromJson(Map<String, dynamic> json) {
    return SpotifyDevice(
      id: json['id'] ?? '',
      isActive: json['is_active'] ?? false,
      isPrivateSession: json['is_private_session'] ?? false,
      isRestricted: json['is_restricted'] ?? false,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      volumePercent: json['volume_percent'],
    );
  }
}

class SpotifySearchResults {
  final List<SpotifyTrack> tracks;
  final List<SpotifyArtist> artists;
  final List<SpotifyAlbum> albums;
  final List<SpotifyPlaylist> playlists;

  SpotifySearchResults({
    required this.tracks,
    required this.artists,
    required this.albums,
    required this.playlists,
  });

  factory SpotifySearchResults.fromJson(Map<String, dynamic> json) {
    return SpotifySearchResults(
      tracks: (json['tracks']?['items'] as List? ?? [])
          .map((item) => SpotifyTrack.fromJson(item))
          .toList(),
      artists: (json['artists']?['items'] as List? ?? [])
          .map((item) => SpotifyArtist.fromJson(item))
          .toList(),
      albums: (json['albums']?['items'] as List? ?? [])
          .map((item) => SpotifyAlbum.fromJson(item))
          .toList(),
      playlists: (json['playlists']?['items'] as List? ?? [])
          .map((item) => SpotifyPlaylist.fromJson(item))
          .toList(),
    );
  }

  factory SpotifySearchResults.empty() {
    return SpotifySearchResults(
      tracks: [],
      artists: [],
      albums: [],
      playlists: [],
    );
  }
}

class SpotifyProfileData {
  final SpotifyUser? user;
  final List<SpotifyTrack> shortTermTracks;
  final List<SpotifyTrack> mediumTermTracks;
  final List<SpotifyTrack> longTermTracks;
  final List<SpotifyArtist> shortTermArtists;
  final List<SpotifyArtist> mediumTermArtists;
  final List<SpotifyArtist> longTermArtists;
  final List<SpotifyTrack> recentTracks;
  final List<SpotifyPlaylist> playlists;
  final List<SpotifyTrack> savedTracks;
  final List<SpotifyAlbum> savedAlbums;
  final List<SpotifyArtist> followedArtists;
  final SpotifyCurrentlyPlaying? currentlyPlaying;
  final SpotifyPlayerState? playerState;
  final List<SpotifyDevice> devices;

  SpotifyProfileData({
    this.user,
    required this.shortTermTracks,
    required this.mediumTermTracks,
    required this.longTermTracks,
    required this.shortTermArtists,
    required this.mediumTermArtists,
    required this.longTermArtists,
    required this.recentTracks,
    required this.playlists,
    required this.savedTracks,
    required this.savedAlbums,
    required this.followedArtists,
    this.currentlyPlaying,
    this.playerState,
    required this.devices,
  });

  // Calculated stats
  int get totalSavedTracks => savedTracks.length;
  int get totalSavedAlbums => savedAlbums.length;
  int get totalPlaylists => playlists.length;
  int get totalFollowedArtists => followedArtists.length;
  int get totalDevices => devices.length;

  // All unique tracks across all time ranges
  Set<String> get allTrackIds => {
    ...shortTermTracks.map((t) => t.id),
    ...mediumTermTracks.map((t) => t.id),
    ...longTermTracks.map((t) => t.id),
  };

  // All unique artists across all time ranges  
  Set<String> get allArtistIds => {
    ...shortTermArtists.map((a) => a.id),
    ...mediumTermArtists.map((a) => a.id),
    ...longTermArtists.map((a) => a.id),
  };

  // Calculate listening diversity
  double get listeningDiversity {
    final totalTracks = shortTermTracks.length + mediumTermTracks.length + longTermTracks.length;
    if (totalTracks == 0) return 0.0;
    return (allTrackIds.length / totalTracks * 100).clamp(0.0, 100.0);
  }

  // Get most played artists across all time ranges
  List<SpotifyArtist> get topArtistsAllTime {
    final artistCount = <String, int>{};
    final artistMap = <String, SpotifyArtist>{};
    
    for (final artist in [...shortTermArtists, ...mediumTermArtists, ...longTermArtists]) {
      artistCount[artist.id] = (artistCount[artist.id] ?? 0) + 1;
      artistMap[artist.id] = artist;
    }
    
    final sorted = artistCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(20).map((entry) => artistMap[entry.key]!).toList();
  }
}
