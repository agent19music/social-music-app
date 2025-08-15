import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_avatar.freezed.dart';
part 'user_avatar.g.dart';

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
