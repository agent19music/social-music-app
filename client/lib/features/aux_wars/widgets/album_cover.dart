import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AlbumCover extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String artist;
  final double size;
  final VoidCallback? onTap;
  final bool isAsset;

  const AlbumCover({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.artist,
    this.size = 200,
    this.onTap,
    this.isAsset = false,
  });

  @override
  State<AlbumCover> createState() => _AlbumCoverState();
}

class _AlbumCoverState extends State<AlbumCover>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.isAsset || widget.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        print(
                            'Asset loading error: $error for ${widget.imageUrl}');
                        return Container(
                          color: Colors.grey[800],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.album,
                                color: Colors.white,
                                size: 60,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load:\n${widget.imageUrl}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.album,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.album,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.size > 250 ? 24 : (widget.size > 200 ? 20 : 18),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'by ${widget.artist}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: widget.size > 250 ? 16 : (widget.size > 200 ? 14 : 12),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
