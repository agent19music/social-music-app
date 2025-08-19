import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/providers/spotify_providers.dart';
import '../../../core/widgets/aux_wars_button.dart';
import 'spotify_stats_screen.dart';

class SpotifySetupScreen extends ConsumerStatefulWidget {
  const SpotifySetupScreen({super.key});

  @override
  ConsumerState<SpotifySetupScreen> createState() => _SpotifySetupScreenState();
}

class _SpotifySetupScreenState extends ConsumerState<SpotifySetupScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  final _clientIdController = TextEditingController();
  final _clientSecretController = TextEditingController();
  final _refreshTokenController = TextEditingController();
  final _accessTokenController = TextEditingController();

  bool _isLoading = false;

  final List<Color> _gradientColors = [
    const Color(0xFF1DB954), // Spotify green
    const Color(0xFF1ed760),
    const Color(0xFF121212), // Spotify dark
    const Color(0xFF191414),
  ];

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _refreshTokenController.dispose();
    _accessTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;
    final isMobile = size.width < 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: _gradientColors,
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Stack(
              children: [
                // Background floating particles
                ...List.generate(20, (index) {
                  final offset = _backgroundController.value * 2 * math.pi;
                  final x = 0.5 + 0.3 * math.cos(offset + index * 0.3);
                  final y = 0.5 + 0.3 * math.sin(offset + index * 0.4);
                  return Positioned(
                    left: x * size.width,
                    top: y * size.height,
                    child: Container(
                      width: 4 + (index % 3) * 2,
                      height: 4 + (index % 3) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1DB954)
                            .withOpacity(0.1 + (index % 4) * 0.1),
                      ),
                    ),
                  );
                }),

                // Top bar
                _buildTopBar(context, isDesktop, isMobile),

                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),

                        // Header
                        Container(
                          width: isMobile ? 100 : 120,
                          height: isMobile ? 100 : 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF1DB954),
                                const Color(0xFF1ed760),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1DB954).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: isMobile ? 40 : 50,
                          ),
                        ),

                        SizedBox(height: isMobile ? 24 : 32),

                        Text(
                          'Connect to Spotify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 28 : 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: isMobile ? 8 : 12),

                        Text(
                          'Enter your Spotify API credentials to unlock music insights',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isMobile ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: isMobile ? 32 : 40),

                        // Setup form
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: isDesktop ? 500 : double.infinity,
                          ),
                          child: Column(
                            children: [
                              _buildInputField(
                                controller: _clientIdController,
                                label: 'Client ID',
                                hint: 'Enter your Spotify Client ID',
                                icon: Icons.key,
                                isMobile: isMobile,
                              ),

                              SizedBox(height: isMobile ? 16 : 20),

                              _buildInputField(
                                controller: _clientSecretController,
                                label: 'Client Secret',
                                hint: 'Enter your Spotify Client Secret',
                                icon: Icons.lock,
                                isMobile: isMobile,
                                isSecret: true,
                              ),

                              SizedBox(height: isMobile ? 16 : 20),

                              _buildInputField(
                                controller: _refreshTokenController,
                                label: 'Refresh Token',
                                hint: 'Enter your refresh token',
                                icon: Icons.refresh,
                                isMobile: isMobile,
                              ),

                              SizedBox(height: isMobile ? 16 : 20),

                              _buildInputField(
                                controller: _accessTokenController,
                                label: 'Access Token (Optional)',
                                hint: 'Enter your access token if available',
                                icon: Icons.token,
                                isMobile: isMobile,
                                optional: true,
                              ),

                              SizedBox(height: isMobile ? 24 : 32),

                              // Connect button
                              _buildConnectButton(isMobile),

                              SizedBox(height: isMobile ? 24 : 32),

                              // Instructions
                              _buildInstructions(isMobile),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop, bool isMobile) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            // Navigation arrow
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white70,
                size: isMobile ? 18 : 24,
              ),
            ),

            const Spacer(),

            // Setup badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8,
                vertical: isMobile ? 3 : 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Setup',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 8 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isMobile,
    bool isSecret = false,
    bool optional = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isSecret,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 14 : 16,
        ),
        decoration: InputDecoration(
          labelText: optional ? '$label (Optional)' : label,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: isMobile ? 12 : 14,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF1DB954),
            size: isMobile ? 20 : 24,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(isMobile ? 16 : 20),
        ),
      ),
    );
  }

  Widget _buildConnectButton(bool isMobile) {
    return AuxWarsButton(
      text: 'Connect to Spotify',
      onPressed: _isLoading ? null : _connectToSpotify,
      isLoading: _isLoading,
      isMobile: isMobile,
      width: double.infinity,
      icon: Icons.music_note,
      color: const Color(0xFF1DB954),
    );
  }

  Widget _buildInstructions(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: isMobile ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'How to get your credentials:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildInstructionStep(
            '1.',
            'Visit developer.spotify.com and create an app',
            isMobile,
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            '2.',
            'Copy your Client ID and Client Secret',
            isMobile,
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            '3.',
            'Use Spotify Web API Console to get tokens',
            isMobile,
          ),
          const SizedBox(height: 8),
          _buildInstructionStep(
            '4.',
            'Enter the credentials above and connect!',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: isMobile ? 20 : 24,
          height: isMobile ? 20 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.2),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: Colors.blue,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ),
      ],
    );
  }

  void _connectToSpotify() async {
    if (_clientIdController.text.isEmpty ||
        _clientSecretController.text.isEmpty ||
        _refreshTokenController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final spotifyService = ref.read(spotifyServiceProvider);

      spotifyService.initialize(
        clientId: _clientIdController.text.trim(),
        clientSecret: _clientSecretController.text.trim(),
        refreshToken: _refreshTokenController.text.trim(),
        accessToken: _accessTokenController.text.trim().isNotEmpty
            ? _accessTokenController.text.trim()
            : null,
      );

      // Test the connection
      final user = await spotifyService.getCurrentUser();

      if (user != null && mounted) {
        // Success! Navigate to stats screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SpotifyStatsScreen(),
          ),
        );
      } else {
        _showError('Failed to connect. Please check your credentials.');
      }
    } catch (e) {
      _showError('Connection failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
