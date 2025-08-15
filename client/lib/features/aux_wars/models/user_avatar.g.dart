// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_avatar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserAvatarImpl _$$UserAvatarImplFromJson(Map<String, dynamic> json) =>
    _$UserAvatarImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      message: json['message'] as String?,
      isActive: json['isActive'] as bool?,
      isWaving: json['isWaving'] as bool?,
      showHeart: json['showHeart'] as bool?,
    );

Map<String, dynamic> _$$UserAvatarImplToJson(_$UserAvatarImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'x': instance.x,
      'y': instance.y,
      'message': instance.message,
      'isActive': instance.isActive,
      'isWaving': instance.isWaving,
      'showHeart': instance.showHeart,
    };
