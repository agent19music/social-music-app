import 'package:flutter/material.dart';
import '../../../core/services/spotify_service.dart';

class DeviceCard extends StatelessWidget {
  final SpotifyPlayerState playerState;
  final bool isMobile;

  const DeviceCard({
    super.key,
    required this.playerState,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1DB954).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 3,
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
                  _getDeviceIcon(playerState.device.type),
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
                      'Active Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      playerState.device.name,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 10,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1DB954).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1DB954).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: const Color(0xFF1DB954),
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isMobile ? 20 : 24),

          // Device details
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device Type',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: isMobile ? 11 : 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (playerState.device.type).toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isMobile ? 13 : 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (playerState.device.volumePercent != null) ...[
                      SizedBox(width: isMobile ? 16 : 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Volume',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isMobile ? 11 : 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${playerState.device.volumePercent}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isMobile ? 13 : 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: isMobile ? 8 : 10),
                                Expanded(
                                  child: Container(
                                    height: isMobile ? 4 : 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: (playerState.device.volumePercent ?? 0) / 100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFF1DB954),
                                              const Color(0xFF1ed760),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: isMobile ? 16 : 20),

                // Playback state
                Row(
                  children: [
                    _buildStatePill(
                      playerState.shuffleState ? 'Shuffle ON' : 'Shuffle OFF',
                      playerState.shuffleState ? Icons.shuffle : Icons.shuffle_outlined,
                      playerState.shuffleState ? const Color(0xFF1DB954) : Colors.grey,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    _buildStatePill(
                      _getRepeatText(playerState.repeatState),
                      _getRepeatIcon(playerState.repeatState),
                      playerState.repeatState != 'off' ? const Color(0xFF1DB954) : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatePill(String text, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 10 : 12,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: isMobile ? 12 : 14,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'computer':
        return Icons.computer;
      case 'smartphone':
        return Icons.phone_android;
      case 'speaker':
        return Icons.speaker;
      case 'tv':
        return Icons.tv;
      case 'game_console':
        return Icons.games;
      default:
        return Icons.devices;
    }
  }

  String _getRepeatText(String repeatState) {
    switch (repeatState) {
      case 'track':
        return 'Repeat One';
      case 'context':
        return 'Repeat All';
      default:
        return 'Repeat OFF';
    }
  }

  IconData _getRepeatIcon(String repeatState) {
    switch (repeatState) {
      case 'track':
        return Icons.repeat_one;
      case 'context':
        return Icons.repeat;
      default:
        return Icons.repeat_outlined;
    }
  }
}
