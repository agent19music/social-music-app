import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/avatar_service.dart';

class InviteFriendsModal extends StatefulWidget {
  final Color accentColor;
  final VoidCallback? onClose;

  const InviteFriendsModal({
    super.key,
    required this.accentColor,
    this.onClose,
  });

  @override
  State<InviteFriendsModal> createState() => _InviteFriendsModalState();
}

class _InviteFriendsModalState extends State<InviteFriendsModal>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<Friend> _friends = [
    Friend('Emma Watson', 'emma_w', true, 'Last seen 2 hours ago'),
    Friend('Ryan Gosling', 'ryangosling', false, 'Online now'),
    Friend('Zendaya Coleman', 'zendaya', true, 'Last seen 1 day ago'),
    Friend('Michael Jordan', 'airjordan23', false, 'Online now'),
    Friend('Taylor Swift', 'taylorswift13', true, 'Last seen 3 hours ago'),
    Friend('The Weeknd', 'theweeknd', false, 'Online now'),
    Friend('Ariana Grande', 'arianagrande', true, 'Last seen 5 hours ago'),
    Friend('Drake', 'champagnepapi', false, 'Online now'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onClose?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background blur
          GestureDetector(
            onTap: _close,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.7),
            ),
          ),

          // Modal content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.75,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: widget.accentColor.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.1),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: widget.accentColor,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Invite Friends to Party',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _close,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Search bar
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: widget.accentColor.withOpacity(0.2),
                                  ),
                                ),
                                child: TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Search friends...',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color:
                                          widget.accentColor.withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ),

                            // Friends list
                            Expanded(
                              child: ListView.builder(
                                itemCount: _friends.length,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemBuilder: (context, index) {
                                  final friend = _friends[index];
                                  return _buildFriendTile(friend, index);
                                },
                              ),
                            ),

                            // Bottom actions
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[900]?.withOpacity(0.3),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        // Copy party link
                                        Clipboard.setData(const ClipboardData(
                                            text:
                                                'https://spotify.com/party/kanye-mbdtf-party'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Party link copied!'),
                                            backgroundColor: widget.accentColor,
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.copy, size: 18),
                                      label: const Text('Copy Link'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: widget.accentColor,
                                        side: BorderSide(
                                            color: widget.accentColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        // Send invites
                                        _close();
                                      },
                                      icon: const Icon(Icons.send, size: 18),
                                      label: const Text('Send Invites'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: widget.accentColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildFriendTile(Friend friend, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[800]!,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: widget.accentColor.withOpacity(0.2),
              child: ClipOval(
                child: Image.network(
                  AvatarService.generateAvatarUrl(friend.username),
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Icon(
                    Icons.person,
                    color: widget.accentColor,
                    size: 24,
                  ),
                ),
              ),
            ),
            if (!friend.isOffline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1A1A1A),
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          friend.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          friend.status,
          style: TextStyle(
            color: friend.isOffline ? Colors.grey[500] : Colors.green[400],
            fontSize: 12,
          ),
        ),
        trailing: Checkbox(
          value: false, // You can manage selection state
          onChanged: (value) {
            HapticFeedback.selectionClick();
            // Handle selection
          },
          activeColor: widget.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class Friend {
  final String name;
  final String username;
  final bool isOffline;
  final String status;

  Friend(this.name, this.username, this.isOffline, this.status);
}
