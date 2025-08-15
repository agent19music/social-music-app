import 'dart:convert';
import 'package:http/http.dart' as http;

class AvatarService {
  static const String _baseUrl = 'https://api.tapback.co';

  static String generateAvatarUrl(
    String seed, {
    int size = 128,
    String style = 'adventurer',
  }) {
    // Using a more reliable avatar service for exact replication
    return 'https://api.dicebear.com/7.x/$style/png?seed=$seed&size=$size&backgroundColor=transparent';
  }

  static List<String> generateMultipleAvatars(int count) {
    final seeds = [
      'felix',
      'aneka',
      'john',
      'mary',
      'alex',
      'sarah',
      'david',
      'emma',
      'michael',
      'olivia',
      'william',
      'sophia',
      'james',
      'isabella',
      'benjamin',
      'charlotte',
      'lucas',
      'amelia',
      'henry',
      'harper'
    ];

    return seeds.take(count).map((seed) => generateAvatarUrl(seed)).toList();
  }
}
