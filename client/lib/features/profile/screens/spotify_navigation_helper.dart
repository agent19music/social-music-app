// HOW TO ACCESS THE SPOTIFY SCREENS 🎵
// =====================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/*
 * NAVIGATION METHODS TO ACCESS SPOTIFY SCREENS
 * ============================================
 * 
 * I've added the Spotify screens to your app's routing system.
 * Here are all the ways you can navigate to them:
 */

class SpotifyNavigationHelper {
  
  // Method 1: From your Profile Screen (EASIEST)
  // ===========================================
  // I've already added beautiful buttons to your ProfileScreen!
  // Just go to Profile tab in your bottom navigation, you'll see:
  // - "Setup Spotify OAuth" button
  // - "View Music Profile" button
  
  
  // Method 2: Direct Navigation (PROGRAMMATIC)
  // =========================================
  static void navigateToSpotifySetup(BuildContext context) {
    context.push('/spotify-setup');
  }
  
  static void navigateToSpotifyProfile(BuildContext context) {
    context.push('/spotify-profile');
  }
  
  
  // Method 3: Navigation with Go Router Names
  // ========================================
  static void navigateToSpotifySetupByName(BuildContext context) {
    context.pushNamed('spotify-setup-standalone');
  }
  
  static void navigateToSpotifyProfileByName(BuildContext context) {
    context.pushNamed('spotify-profile-standalone');
  }
  
  
  // Method 4: Navigation from Profile Sub-routes
  // ============================================
  static void navigateToSpotifySetupFromProfile(BuildContext context) {
    context.push('/profile/spotify-setup');
  }
  
  static void navigateToSpotifyProfileFromProfile(BuildContext context) {
    context.push('/profile/spotify-profile');
  }
  
  
  // Example Usage in Any Widget
  // ===========================
  static Widget buildSpotifyButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => navigateToSpotifySetup(context),
          child: const Text('Setup Spotify'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => navigateToSpotifyProfile(context),
          child: const Text('View Spotify Profile'),
        ),
      ],
    );
  }
}

/*
 * QUICK START GUIDE 🚀
 * ====================
 * 
 * 1. IMMEDIATE ACCESS (No coding needed):
 *    - Open your app
 *    - Go to the Profile tab (bottom navigation)
 *    - You'll see beautiful Spotify integration buttons!
 * 
 * 2. Setup Process:
 *    - Tap "Setup Spotify OAuth" first
 *    - Follow the guided setup (I made it super user-friendly!)
 *    - Enter your Spotify app credentials
 *    - Complete the OAuth flow
 * 
 * 3. View Your Music Data:
 *    - After setup, tap "View Music Profile"
 *    - Enjoy your comprehensive music analytics!
 * 
 * 4. Direct URL Access (for testing):
 *    - /spotify-setup - OAuth setup screen
 *    - /spotify-profile - Comprehensive profile screen
 * 
 * ROUTES ADDED TO YOUR APP:
 * ========================
 * - /spotify-setup (standalone access)
 * - /spotify-profile (standalone access)  
 * - /profile/spotify-setup (from profile)
 * - /profile/spotify-profile (from profile)
 * 
 * The screens are now fully integrated into your existing
 * app architecture using your GoRouter setup!
 */

// Example of how to add a floating action button anywhere
class ExampleScreenWithSpotifyAccess extends StatelessWidget {
  const ExampleScreenWithSpotifyAccess({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: const Center(
        child: Text('Any screen in your app'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/spotify-profile'),
        backgroundColor: const Color(0xFF1DB954),
        icon: const Icon(Icons.music_note),
        label: const Text('Spotify'),
      ),
    );
  }
}
