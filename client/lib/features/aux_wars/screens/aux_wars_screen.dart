import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../widgets/animated_user_avatar.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/album_cover.dart';
import '../widgets/invite_friends_modal.dart';
import '../services/avatar_service.dart';
import '../services/smart_color_service.dart';

class AuxWarsScreen extends StatefulWidget {
  const AuxWarsScreen({super.key});

  @override
  State<AuxWarsScreen> createState() => _AuxWarsScreenState();
}

class _AuxWarsScreenState extends State<AuxWarsScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _participantController;
  late AnimationController _skipController;
  late List<UserParticipant> participants;

  // Album state
  String _currentAlbumFile = 'mbdtfaa.jpg';
  late AlbumData _currentAlbumData;

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

    _participantController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _skipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _backgroundController.repeat();
    _currentAlbumData = SmartColorService.getAlbumData(_currentAlbumFile);
    print(
        'Loading album: $_currentAlbumFile with data: ${_currentAlbumData.title}');
    _initializeParticipants();

    // Start periodic animations for participants
    _startPeriodicAnimations();
  }

  void _initializeParticipants() {
    final avatars = AvatarService.generateMultipleAvatars(12);
    participants = [
      UserParticipant(
        id: '1',
        name: 'Alex',
        avatarUrl: avatars[0],
        x: 0.15,
        y: 0.25,
        message:
            "Runaway is such a masterpiece! This beat hits different every time 🔥 #kanyewest #mbdtf",
        showMessage: true,
        isWaving: false,
      ),
      UserParticipant(
        id: '2',
        name: 'Emma',
        avatarUrl: avatars[1],
        x: 0.85,
        y: 0.2,
        isWaving: true,
      ),
      UserParticipant(
        id: '3',
        name: 'John',
        avatarUrl: avatars[2],
        x: 0.75,
        y: 0.4,
        showHeart: true,
      ),
      UserParticipant(
        id: '4',
        name: 'Sarah',
        avatarUrl: avatars[3],
        x: 0.2,
        y: 0.6,
      ),
      UserParticipant(
        id: '5',
        name: 'Mike',
        avatarUrl: avatars[4],
        x: 0.8,
        y: 0.65,
      ),
      UserParticipant(
        id: '6',
        name: 'Lisa',
        avatarUrl: avatars[5],
        x: 0.1,
        y: 0.8,
        message:
            "This listening party is amazing! We're all vibing to Kanye together 🎵 #mbdtf #runaway",
        showMessage: true,
      ),
      UserParticipant(
        id: '7',
        name: 'David',
        avatarUrl: avatars[6],
        x: 0.9,
        y: 0.85,
      ),
      UserParticipant(
        id: '8',
        name: 'Anna',
        avatarUrl: avatars[7],
        x: 0.65,
        y: 0.75,
        isWaving: true,
      ),
      UserParticipant(
        id: '9',
        name: 'Chris',
        avatarUrl: avatars[8],
        x: 0.45,
        y: 0.85,
      ),
      UserParticipant(
        id: '10',
        name: 'Maya',
        avatarUrl: avatars[9],
        x: 0.05,
        y: 0.4,
        message:
            "Kanye's production on this album is legendary! 🐐 #kanyewest #mbdtf",
        showMessage: true,
      ),
    ];
  }

  void _startPeriodicAnimations() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _animateRandomParticipant();
      }
    });
  }

  void _animateRandomParticipant() {
    final random = math.Random();
    final index = random.nextInt(participants.length);

    setState(() {
      // Reset all animations
      for (var p in participants) {
        p.isWaving = false;
        p.showHeart = false;
      }

      // Animate random participant
      if (random.nextBool()) {
        participants[index].isWaving = true;
      } else {
        participants[index].showHeart = true;
      }
    });

    // Schedule next animation
    Future.delayed(Duration(seconds: 3 + random.nextInt(4)), () {
      if (mounted) {
        _animateRandomParticipant();
      }
    });
  }

  void _skipToRandomAlbum() async {
    HapticFeedback.mediumImpact();

    await _skipController.forward();

    setState(() {
      _currentAlbumFile = SmartColorService.getRandomAlbum();
      _currentAlbumData = SmartColorService.getAlbumData(_currentAlbumFile);
      print(
          'Skipped to album: $_currentAlbumFile - ${_currentAlbumData.title}');
      _updateParticipantMessages();
    });

    _skipController.reverse();
  }

  void _updateParticipantMessages() {
    final messages = [
      "This ${_currentAlbumData.artist} track is incredible! 🔥",
      "Love this album! ${_currentAlbumData.title} is a masterpiece",
      "Can't stop listening to ${_currentAlbumData.song} on repeat!",
      "${_currentAlbumData.artist} really knows how to make music 🎵",
      "This beat hits different! Amazing production",
      "Vibing so hard to this right now! 💫",
    ];

    final random = math.Random();
    for (int i = 0; i < participants.length; i++) {
      if (participants[i].showMessage) {
        participants[i].message = messages[random.nextInt(messages.length)];
      }
    }
  }

  void _showInviteFriendsModal() {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => InviteFriendsModal(
        accentColor: _currentAlbumData.accentColor,
      ),
    );
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _participantController.dispose();
    _skipController.dispose();
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
            colors: SmartColorService.generateGradientColors(_currentAlbumData),
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
                        color: _currentAlbumData.sparkColors[
                                index % _currentAlbumData.sparkColors.length]
                            .withOpacity(0.1 + (index % 4) * 0.1),
                      ),
                    ),
                  );
                }),

                // Top bar
                _buildTopBar(context, isDesktop, isMobile),

                // Main content
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: isMobile ? 80 : 60),

                        // Listener count
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // User avatars stack
                              SizedBox(
                                width: isMobile ? 80 : 100,
                                height: isMobile ? 24 : 32,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      child: CircleAvatar(
                                        radius: isMobile ? 12 : 16,
                                        backgroundColor: Colors.blue,
                                        child: ClipOval(
                                          child: Image.network(
                                            AvatarService.generateAvatarUrl(
                                                'user1'),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stack) => Icon(
                                                    Icons.person,
                                                    size: isMobile ? 12 : 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: isMobile ? 16 : 20,
                                      child: CircleAvatar(
                                        radius: isMobile ? 12 : 16,
                                        backgroundColor: Colors.green,
                                        child: ClipOval(
                                          child: Image.network(
                                            AvatarService.generateAvatarUrl(
                                                'user2'),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stack) => Icon(
                                                    Icons.person,
                                                    size: isMobile ? 12 : 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: isMobile ? 32 : 40,
                                      child: CircleAvatar(
                                        radius: isMobile ? 12 : 16,
                                        backgroundColor: Colors.purple,
                                        child: ClipOval(
                                          child: Image.network(
                                            AvatarService.generateAvatarUrl(
                                                'user3'),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stack) => Icon(
                                                    Icons.person,
                                                    size: isMobile ? 12 : 16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: isMobile ? 48 : 60,
                                      child: Container(
                                        width: isMobile ? 24 : 32,
                                        height: isMobile ? 24 : 32,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF4CAF50),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '+',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isMobile ? 14 : 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _showInviteFriendsModal,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 8 : 12,
                                    vertical: isMobile ? 4 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _currentAlbumData.accentColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _currentAlbumData.accentColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Invite Friends',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isMobile ? 10 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Listener count text
                        Text(
                          '4,823,129 Listening',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isMobile ? 14 : (isDesktop ? 18 : 16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: isMobile ? 30 : 40),

                        // Album cover with skip functionality
                        GestureDetector(
                          onTap: _skipToRandomAlbum,
                          child: AnimatedBuilder(
                            animation: _skipController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 - (_skipController.value * 0.1),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Aura rings
                                    for (int i = 0; i < 3; i++)
                                      Container(
                                        width: (isMobile
                                                ? 200
                                                : (isDesktop ? 280 : 240)) +
                                            (i * 40),
                                        height: (isMobile
                                                ? 200
                                                : (isDesktop ? 280 : 240)) +
                                            (i * 40),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _currentAlbumData.accentColor
                                                .withOpacity(0.2 - (i * 0.05)),
                                            width: 2 - (i * 0.5),
                                          ),
                                        ),
                                      ),

                                    // Album cover
                                    AlbumCover(
                                      imageUrl:
                                          'assets/images/albumart/$_currentAlbumFile',
                                      title: _currentAlbumData.title,
                                      artist: _currentAlbumData.artist,
                                      size: isMobile
                                          ? 200
                                          : (isDesktop ? 280 : 240),
                                      isAsset: true,
                                    ),

                                    // Skip hint overlay
                                    Positioned(
                                      bottom: -40,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: _currentAlbumData.accentColor
                                              .withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _currentAlbumData
                                                  .accentColor
                                                  .withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.skip_next,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Tap to skip',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: isMobile ? 100 : 120),
                      ],
                    ),
                  ),
                ),

                // Animated participants
                ...participants
                    .map((participant) => _buildParticipant(
                          context,
                          participant,
                          size,
                          isMobile,
                        ))
                    .toList(),

                // Bottom player
                _buildBottomPlayer(context, isDesktop, isMobile),
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
            // Spotify logo
            Container(
              width: isMobile ? 28 : 32,
              height: isMobile ? 28 : 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1DB954),
              ),
              child: Icon(
                Icons.music_note,
                color: Colors.white,
                size: isMobile ? 14 : 18,
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            // Navigation arrows
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white70,
                size: isMobile ? 18 : 24,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: isMobile ? 18 : 24,
              ),
            ),

            SizedBox(width: isMobile ? 12 : 16),

            // Event info
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
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Text(
                      'EVENT',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: isMobile ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    '${_currentAlbumData.artist.toUpperCase()}\'S ALBUM STREAMING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Right side controls - hide some on mobile
            if (!isMobile) ...[
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_camera_outlined,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'PARTY',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.playlist_play,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          'PLAYLIST',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],

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
                'Exclusive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 8 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            if (!isMobile) ...[
              const SizedBox(width: 16),

              // Window controls
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF5F57),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFBD2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF28CA42),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParticipant(BuildContext context, UserParticipant participant,
      Size screenSize, bool isMobile) {
    final left = participant.x * screenSize.width;
    final top = participant.y * screenSize.height;
    final avatarSize = isMobile ? 50.0 : 60.0;

    return Positioned(
      left: left - (avatarSize / 2), // Center the avatar
      top: top - (avatarSize / 2),
      child: Column(
        children: [
          AnimatedUserAvatar(
            avatarUrl: participant.avatarUrl,
            name: participant.name,
            size: avatarSize,
            isWaving: participant.isWaving,
            showHeart: participant.showHeart,
            isActive: true,
            onTap: () {
              // Handle avatar tap
            },
          ),
          if (participant.showMessage && participant.message != null)
            Container(
              constraints: BoxConstraints(
                maxWidth: isMobile ? 150 : 200,
              ),
              margin: const EdgeInsets.only(top: 8),
              child: ChatBubble(
                message: participant.message!,
                userName: participant.name,
                bubbleColor: const Color(0xFF2C2C2C),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomPlayer(
      BuildContext context, bool isDesktop, bool isMobile) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: isMobile ? 70 : 80,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Album art and track info
            Container(
              width: isMobile ? 48 : 56,
              height: isMobile ? 48 : 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[800],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/images/albumart/$_currentAlbumFile',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.album, color: Colors.white),
                ),
              ),
            ),

            SizedBox(width: isMobile ? 8 : 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentAlbumData.song,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _currentAlbumData.artist,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isMobile ? 10 : 12,
                    ),
                  ),
                ],
              ),
            ),

            // Controls
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: isMobile ? 20 : 24,
                  ),
                ),
                SizedBox(width: isMobile ? 4 : 8),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white70,
                    size: isMobile ? 20 : 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UserParticipant {
  final String id;
  final String name;
  final String avatarUrl;
  final double x;
  final double y;
  String? message;
  bool showMessage;
  bool isWaving;
  bool showHeart;

  UserParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.x,
    required this.y,
    this.message,
    this.showMessage = false,
    this.isWaving = false,
    this.showHeart = false,
  });
}
