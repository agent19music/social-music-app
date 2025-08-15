import 'package:flutter/material.dart';

class MusicPreferencesScreen extends StatelessWidget {
  const MusicPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music Preferences')),
      body: const Center(child: Text('Music Preferences Screen')),
    );
  }
}
