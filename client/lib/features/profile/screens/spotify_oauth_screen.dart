import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../core/services/spotify_service.dart';
import '../../../core/widgets/aux_wars_button.dart';

class SpotifyOAuthScreen extends ConsumerStatefulWidget {
  const SpotifyOAuthScreen({super.key});

  @override
  ConsumerState<SpotifyOAuthScreen> createState() => _SpotifyOAuthScreenState();
}

class _SpotifyOAuthScreenState extends ConsumerState<SpotifyOAuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  late TextEditingController _clientIdController;
  late TextEditingController _clientSecretController;
  late TextEditingController _authCodeController;

  final List<Color> _gradientColors = [
    const Color(0xFF1DB954), // Spotify green
    const Color(0xFF1ed760),
    const Color(0xFF121212), // Spotify dark
    const Color(0xFF191414),
  ];

  String _authUrl = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _showCodeInput = false;

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _clientIdController = TextEditingController();
    _clientSecretController = TextEditingController();
    _authCodeController = TextEditingController();

    _backgroundController.repeat();
    _cardController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _cardController.dispose();
    _clientIdController.dispose();
    _clientSecretController.dispose();
    _authCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                      width: 3 + (index % 3) * 2,
                      height: 3 + (index % 3) * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1DB954).withOpacity(0.05 + (index % 4) * 0.05),
                      ),
                    ),
                  );
                }),

                // Top bar
                _buildTopBar(context, isMobile),

                // Main content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: isMobile ? 20 : 32,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        _buildHeader(isMobile),
                        SizedBox(height: isMobile ? 32 : 48),
                        _buildSetupCard(isMobile),
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

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            // Spotify logo
            Container(
              width: isMobile ? 32 : 36,
              height: isMobile ? 32 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1DB954),
                    const Color(0xFF1ed760),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: isMobile ? 16 : 20,
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white70,
                size: isMobile ? 18 : 24,
              ),
            ),

            SizedBox(width: isMobile ? 8 : 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 8,
                      vertical: isMobile ? 2 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DB954).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF1DB954).withOpacity(0.5)),
                    ),
                    child: Text(
                      'SETUP',
                      style: TextStyle(
                        color: const Color(0xFF1DB954),
                        fontSize: isMobile ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'SPOTIFY AUTHORIZATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardController.value) * 50),
          child: Opacity(
            opacity: _cardController.value,
            child: Column(
              children: [
                Container(
                  width: isMobile ? 80 : 100,
                  height: isMobile ? 80 : 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1DB954),
                        const Color(0xFF1ed760),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DB954).withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.link,
                    color: Colors.white,
                    size: isMobile ? 40 : 50,
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                Text(
                  'Connect Spotify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 24 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                Text(
                  'Link your Spotify account to unlock comprehensive music analytics',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetupCard(bool isMobile) {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _cardController.value) * 100),
          child: Opacity(
            opacity: _cardController.value * 0.9 + 0.1,
            child: Container(
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF1DB954).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1DB954).withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 8 : 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1DB954),
                              const Color(0xFF1ed760),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.security,
                          color: Colors.white,
                          size: isMobile ? 16 : 20,
                        ),
                      ),
                      SizedBox(width: isMobile ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OAuth Setup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 18 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Secure authentication with Spotify',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobile ? 24 : 32),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: isMobile ? 16 : 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),
                  ],

                  // Step indicator
                  _buildStepIndicator(isMobile),

                  SizedBox(height: isMobile ? 20 : 24),

                  // Setup forms
                  if (!_showCodeInput) ...[
                    _buildCredentialsForm(isMobile),
                  ] else ...[
                    _buildAuthCodeForm(isMobile),
                  ],

                  SizedBox(height: isMobile ? 24 : 32),

                  // Instructions
                  _buildInstructions(isMobile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepIndicator(bool isMobile) {
    return Row(
      children: [
        _buildStepDot(1, !_showCodeInput, true, isMobile),
        Expanded(
          child: Container(
            height: 2,
            color: _showCodeInput 
                ? const Color(0xFF1DB954) 
                : Colors.white.withOpacity(0.3),
          ),
        ),
        _buildStepDot(2, _showCodeInput, _authUrl.isNotEmpty, isMobile),
      ],
    );
  }

  Widget _buildStepDot(int step, bool isActive, bool isCompleted, bool isMobile) {
    return Container(
      width: isMobile ? 32 : 40,
      height: isMobile ? 32 : 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive || isCompleted
            ? LinearGradient(
                colors: [
                  const Color(0xFF1DB954),
                  const Color(0xFF1ed760),
                ],
              )
            : null,
        color: isActive || isCompleted 
            ? null 
            : Colors.white.withOpacity(0.2),
        border: Border.all(
          color: isActive || isCompleted 
              ? Colors.transparent 
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        isCompleted 
            ? Icons.check 
            : step == 1 
                ? Icons.key 
                : Icons.code,
        color: Colors.white,
        size: isMobile ? 14 : 18,
      ),
    );
  }

  Widget _buildCredentialsForm(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Enter Your Spotify App Credentials',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        // Client ID
        _buildInputField(
          controller: _clientIdController,
          label: 'Client ID',
          hint: 'Your Spotify app Client ID',
          icon: Icons.fingerprint,
          isMobile: isMobile,
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Client Secret
        _buildInputField(
          controller: _clientSecretController,
          label: 'Client Secret',
          hint: 'Your Spotify app Client Secret',
          icon: Icons.lock,
          isPassword: true,
          isMobile: isMobile,
        ),
        
        SizedBox(height: isMobile ? 24 : 32),
        
        // Generate Auth URL button
        SizedBox(
          width: double.infinity,
          child: AuxWarsButton(
            text: 'Generate Authorization URL',
            onPressed: _isLoading ? null : _generateAuthUrl,
            icon: Icons.link,
            isMobile: isMobile,
            color: const Color(0xFF1DB954),
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCodeForm(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: Authorize and Enter Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        
        // Auth URL display
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1DB954).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.link,
                    color: const Color(0xFF1DB954),
                    size: isMobile ? 14 : 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Authorization URL',
                    style: TextStyle(
                      color: const Color(0xFF1DB954),
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _authUrl));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('URL copied to clipboard')),
                      );
                    },
                    icon: Icon(
                      Icons.copy,
                      color: Colors.white.withOpacity(0.7),
                      size: isMobile ? 16 : 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _authUrl,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isMobile ? 10 : 12,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        // Open URL button
        SizedBox(
          width: double.infinity,
          child: AuxWarsButton(
            text: 'Open in Browser',
            onPressed: () {
              // TODO: Launch URL in browser
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please copy the URL and open in browser')),
              );
            },
            icon: Icons.open_in_browser,
            isMobile: isMobile,
            color: Colors.blue,
          ),
        ),
        
        SizedBox(height: isMobile ? 20 : 24),
        
        // Authorization code input
        _buildInputField(
          controller: _authCodeController,
          label: 'Authorization Code',
          hint: 'Paste the code from the callback URL',
          icon: Icons.code,
          isMobile: isMobile,
        ),
        
        SizedBox(height: isMobile ? 24 : 32),
        
        // Complete setup button
        SizedBox(
          width: double.infinity,
          child: AuxWarsButton(
            text: 'Complete Setup',
            onPressed: _isLoading ? null : _completeSetup,
            icon: Icons.check_circle,
            isMobile: isMobile,
            color: const Color(0xFF1DB954),
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 14 : 16,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: isMobile ? 14 : 16,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFF1DB954),
              size: isMobile ? 20 : 24,
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1DB954),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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
                size: isMobile ? 16 : 20,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                'Instructions',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildInstruction('1.', 'Create a Spotify app at developer.spotify.com', isMobile),
          const SizedBox(height: 8),
          _buildInstruction('2.', 'Add redirect URI: http://localhost:8080/callback', isMobile),
          const SizedBox(height: 8),
          _buildInstruction('3.', 'Enter your Client ID and Client Secret above', isMobile),
          const SizedBox(height: 8),
          _buildInstruction('4.', 'Click the authorization URL and approve access', isMobile),
          const SizedBox(height: 8),
          _buildInstruction('5.', 'Copy the "code" parameter from the callback URL', isMobile),
        ],
      ),
    );
  }

  Widget _buildInstruction(String number, String text, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            color: Colors.blue,
            fontSize: isMobile ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
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

  Future<void> _generateAuthUrl() async {
    if (_clientIdController.text.isEmpty || _clientSecretController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both Client ID and Client Secret';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final spotifyService = SpotifyService();
      spotifyService.initialize(
        clientId: _clientIdController.text,
        clientSecret: _clientSecretController.text,
      );

      final authUrl = spotifyService.getAuthorizationUrl();
      
      setState(() {
        _authUrl = authUrl;
        _showCodeInput = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate authorization URL: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _completeSetup() async {
    if (_authCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the authorization code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final spotifyService = SpotifyService();
      await spotifyService.exchangeCodeForTokens(_authCodeController.text);
      
      // Success! Navigate back or to profile
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Spotify connected successfully!'),
            backgroundColor: Color(0xFF1DB954),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to complete setup: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}
