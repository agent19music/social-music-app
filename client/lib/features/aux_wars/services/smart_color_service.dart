import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SmartColorService {
  static const Map<String, AlbumData> _albumDatabase = {
    'mbdtfaa.jpg': AlbumData(
      title: 'My Beautiful Dark Twisted Fantasy',
      artist: 'Kanye West',
      song: 'Runaway',
      primaryColor: Color(0xFF8B0000),
      accentColor: Color(0xFFFF6B35),
      sparkColors: [Color(0xFFFF6B35), Color(0xFFFFD23F), Color(0xFF8B0000)],
    ),
    'astroworld.jpg': AlbumData(
      title: 'ASTROWORLD',
      artist: 'Travis Scott',
      song: 'SICKO MODE',
      primaryColor: Color(0xFF1E3A8A),
      accentColor: Color(0xFFEAB308),
      sparkColors: [Color(0xFFEAB308), Color(0xFF3B82F6), Color(0xFF1E3A8A)],
    ),
    'igor.jpg': AlbumData(
      title: 'IGOR',
      artist: 'Tyler, The Creator',
      song: 'EARFQUAKE',
      primaryColor: Color(0xFFDB2777),
      accentColor: Color(0xFF10B981),
      sparkColors: [Color(0xFF10B981), Color(0xFFDB2777), Color(0xFFEF4444)],
    ),
    'AM.jpg': AlbumData(
      title: 'AM',
      artist: 'Arctic Monkeys',
      song: 'Do I Wanna Know?',
      primaryColor: Color(0xFF1F2937),
      accentColor: Color(0xFFEF4444),
      sparkColors: [Color(0xFFEF4444), Color(0xFF6B7280), Color(0xFF1F2937)],
    ),
    'gkmc.jpg': AlbumData(
      title: 'good kid, m.A.A.d city',
      artist: 'Kendrick Lamar',
      song: 'm.A.A.d city',
      primaryColor: Color(0xFF0F172A),
      accentColor: Color(0xFF06B6D4),
      sparkColors: [Color(0xFF06B6D4), Color(0xFF14B8A6), Color(0xFF0F172A)],
    ),
    'beerbongsandbentlys.jpg': AlbumData(
      title: 'beerbongs & bentleys',
      artist: 'Post Malone',
      song: 'rockstar',
      primaryColor: Color(0xFF7C2D12),
      accentColor: Color(0xFFF59E0B),
      sparkColors: [Color(0xFFF59E0B), Color(0xFFDC2626), Color(0xFF7C2D12)],
    ),
    'dontsmileatmebillieeilish.jpg': AlbumData(
      title: 'dont smile at me',
      artist: 'Billie Eilish',
      song: 'lovely',
      primaryColor: Color(0xFF065F46),
      accentColor: Color(0xFF84CC16),
      sparkColors: [Color(0xFF84CC16), Color(0xFF22C55E), Color(0xFF065F46)],
    ),
    'birdsinthetrapsingmcknight.jpg': AlbumData(
      title: 'Birds in the Trap Sing McKnight',
      artist: 'Travis Scott',
      song: 'goosebumps',
      primaryColor: Color(0xFF7C2D12),
      accentColor: Color(0xFFF97316),
      sparkColors: [Color(0xFFF97316), Color(0xFFEAB308), Color(0xFF7C2D12)],
    ),
    '_xxxtentacion.jpg': AlbumData(
      title: '17',
      artist: 'XXXTentacion',
      song: 'Jocelyn Flores',
      primaryColor: Color(0xFF1F2937),
      accentColor: Color(0xFF8B5CF6),
      sparkColors: [Color(0xFF8B5CF6), Color(0xFFA855F7), Color(0xFF1F2937)],
    ),
    'notallheroeswearcapes.jpg': AlbumData(
      title: 'Not All Heroes Wear Capes',
      artist: 'Metro Boomin',
      song: 'No Complaints',
      primaryColor: Color(0xFF0F172A),
      accentColor: Color(0xFFF59E0B),
      sparkColors: [Color(0xFFF59E0B), Color(0xFFEAB308), Color(0xFF0F172A)],
    ),
    'psychodramadave.jpg': AlbumData(
      title: 'PSYCHODRAMA',
      artist: 'Dave',
      song: 'Location',
      primaryColor: Color(0xFF7C2D12),
      accentColor: Color(0xFF06B6D4),
      sparkColors: [Color(0xFF06B6D4), Color(0xFF0EA5E9), Color(0xFF7C2D12)],
    ),
    'wereallaloneinthistogether.jpg': AlbumData(
      title: "We're All Alone In This Together",
      artist: 'Dave',
      song: 'Clash',
      primaryColor: Color(0xFF1F2937),
      accentColor: Color(0xFFEF4444),
      sparkColors: [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF1F2937)],
    ),
  };

  static AlbumData getAlbumData(String fileName) {
    return _albumDatabase[fileName] ?? _getDefaultAlbumData();
  }

  static AlbumData _getDefaultAlbumData() {
    return const AlbumData(
      title: 'Unknown Album',
      artist: 'Unknown Artist',
      song: 'Unknown Song',
      primaryColor: Color(0xFF1F2937),
      accentColor: Color(0xFF3B82F6),
      sparkColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8), Color(0xFF1F2937)],
    );
  }

  static List<String> getAllAlbumFiles() {
    return _albumDatabase.keys.toList();
  }

  static String getRandomAlbum() {
    final albums = getAllAlbumFiles();
    return albums[math.Random().nextInt(albums.length)];
  }

  // Future feature: Actual color extraction from image
  static Future<AlbumData> extractColorsFromImage(String assetPath) async {
    try {
      // For now, use predefined colors, but this could be enhanced
      // with actual image color extraction using packages like palette_generator
      final fileName = assetPath.split('/').last;
      return getAlbumData(fileName);
    } catch (e) {
      return _getDefaultAlbumData();
    }
  }

  static Color adjustColorForBackground(Color baseColor,
      {double opacity = 0.8}) {
    return Color.fromRGBO(
      baseColor.red,
      baseColor.green,
      baseColor.blue,
      opacity,
    );
  }

  static List<Color> generateGradientColors(AlbumData album) {
    return [
      album.primaryColor.withOpacity(0.8),
      album.primaryColor.withOpacity(0.6),
      album.primaryColor.withOpacity(0.4),
      Colors.black,
    ];
  }
}

class AlbumData {
  final String title;
  final String artist;
  final String song;
  final Color primaryColor;
  final Color accentColor;
  final List<Color> sparkColors;

  const AlbumData({
    required this.title,
    required this.artist,
    required this.song,
    required this.primaryColor,
    required this.accentColor,
    required this.sparkColors,
  });
}
