// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listening_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ListeningEventImpl _$$ListeningEventImplFromJson(Map<String, dynamic> json) =>
    _$ListeningEventImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      albumCover: json['albumCover'] as String,
      eventName: json['eventName'] as String,
      eventHost: json['eventHost'] as String,
      listenerCount: (json['listenerCount'] as num).toInt(),
      participants: (json['participants'] as List<dynamic>)
          .map((e) => UserAvatar.fromJson(e as Map<String, dynamic>))
          .toList(),
      isExclusive: json['isExclusive'] as bool,
      isLive: json['isLive'] as bool,
    );

Map<String, dynamic> _$$ListeningEventImplToJson(
        _$ListeningEventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'albumCover': instance.albumCover,
      'eventName': instance.eventName,
      'eventHost': instance.eventHost,
      'listenerCount': instance.listenerCount,
      'participants': instance.participants,
      'isExclusive': instance.isExclusive,
      'isLive': instance.isLive,
    };

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
