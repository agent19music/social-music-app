import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:music_social_client/core/theme/app_theme.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/services.dart';

class MusicCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isPlaying;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;

  const MusicCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.isPlaying = false,
    this.width,
    this.height,
    this.borderRadius,
    this.gradientColors,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardWidth = widget.width ?? 180.0;
    final cardHeight = widget.height ?? 240.0;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - (_controller.value * 0.05);
          
          return Transform.scale(
            scale: scale,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: isDark
                    ? AppTheme.cardShadowDark
                    : AppTheme.cardShadowLight,
              ),
              child: ClipRRect(
                borderRadius: widget.borderRadius ??
                    BorderRadius.circular(AppTheme.radiusLarge),
                child: Stack(
                  children: [
                    // Album Artwork
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: isDark
                              ? AppTheme.darkCard
                              : AppTheme.lightDivider,
                          highlightColor: isDark
                              ? AppTheme.darkDivider
                              : AppTheme.lightBackground,
                          child: Container(
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark
                              ? AppTheme.darkCard
                              : AppTheme.lightSurface,
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 48,
                            color: isDark
                                ? AppTheme.darkTextTertiary
                                : AppTheme.lightTextTertiary,
                          ),
                        ),
                      ),
                    ),
                    
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: widget.gradientColors ??
                                [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.9),
                                ],
                            stops: const [0.0, 0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Content
                    Positioned(
                      left: AppTheme.spacing12,
                      right: AppTheme.spacing12,
                      bottom: AppTheme.spacing12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Playing Indicator
                          if (widget.isPlaying) ...[
                            _PlayingIndicator(),
                            const SizedBox(height: AppTheme.spacing8),
                          ],
                          
                          // Title
                          Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: AppTheme.spacing4),
                          
                          // Subtitle
                          Text(
                            widget.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          // Trailing Widget
                          if (widget.trailing != null) ...[
                            const SizedBox(height: AppTheme.spacing8),
                            widget.trailing!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(
              effects: [
                if (_isPressed)
                  const ScaleEffect(
                    duration: Duration(milliseconds: 150),
                    begin: Offset(1, 1),
                    end: Offset(0.95, 0.95),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlayingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Container(
          width: 3,
          height: 12,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        )
            .animate(
              onPlay: (controller) => controller.repeat(),
            )
            .scaleY(
              begin: 0.3,
              end: 1.0,
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeInOut,
            )
            .then()
            .scaleY(
              begin: 1.0,
              end: 0.3,
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeInOut,
            ),
      ),
    );
  }
}
