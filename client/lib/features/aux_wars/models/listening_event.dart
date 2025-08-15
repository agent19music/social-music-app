import 'package:freezed_annotation/freezed_annotation.dart';

part 'listening_event.freezed.dart';
part 'listening_event.g.dart';

@freezed
class ListeningEvent with _$ListeningEvent {
  const factory ListeningEvent({
    required String id,
    required String title,
    required String artist,
    required String albumCover,
    required String eventName,
    required String eventHost,
    required int listenerCount,
    required List<UserAvatar> participants,
    required bool isExclusive,
    required bool isLive,
  }) = _ListeningEvent;

  factory ListeningEvent.fromJson(Map<String, dynamic> json) =>
      _$ListeningEventFromJson(json);
}

@freezed
class UserAvatar with _$UserAvatar {
  const factory UserAvatar({
    required String id,
    required String name,
    required String avatarUrl,
    required double x, // Position as percentage of screen width
    required double y, // Position as percentage of screen height
    String? message,
    bool? isActive,
    bool? isWaving,
    bool? showHeart,
  }) = _UserAvatar;

  factory UserAvatar.fromJson(Map<String, dynamic> json) =>
      _$UserAvatarFromJson(json);
}
