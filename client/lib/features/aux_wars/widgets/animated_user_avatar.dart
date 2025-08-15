import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnimatedUserAvatar extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final double size;
  final bool isWaving;
  final bool showHeart;
  final bool isActive;
  final VoidCallback? onTap;

  const AnimatedUserAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 60,
    this.isWaving = false,
    this.showHeart = false,
    this.isActive = true,
    this.onTap,
  });

  @override
  State<AnimatedUserAvatar> createState() => _AnimatedUserAvatarState();
}

class _AnimatedUserAvatarState extends State<AnimatedUserAvatar>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _heartController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedUserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isWaving && !oldWidget.isWaving) {
      _waveController.forward().then((_) => _waveController.reset());
    }

    if (widget.showHeart && !oldWidget.showHeart) {
      _heartController.forward().then((_) => _heartController.reset());
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _heartController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pulse effect for active users
          if (widget.isActive)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: widget.size + 10,
                  height: widget.size + 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        0.3 + (_pulseController.value * 0.4),
                      ),
                      width: 2 + (_pulseController.value * 2),
                    ),
                  ),
                );
              },
            ),

          // Avatar
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Transform.rotate(
                angle: widget.isWaving ? _waveController.value * 0.2 : 0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.avatarUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Wave emoji
          if (widget.isWaving)
            Positioned(
              top: -10,
              right: -5,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1 + (_waveController.value * 0.3),
                    child: const Text(
                      '👋',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
            ),

          // Heart emoji
          if (widget.showHeart)
            Positioned(
              top: -5,
              right: -5,
              child: AnimatedBuilder(
                animation: _heartController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _heartController.value,
                    child: Opacity(
                      opacity: 1 - _heartController.value,
                      child: const Text(
                        '❤️',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
