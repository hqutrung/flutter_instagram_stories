// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoryData _$StoryDataFromJson(Map<String, dynamic> json) => StoryData(
      filetype: json['filetype'] as String?,
      url: (json['url'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      ),
    )
      ..fileTitle = (json['fileTitle'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String?),
      )
      ..expiryTime = StoryData._fromJson(json['expiryTime'] as Timestamp?);

Map<String, dynamic> _$StoryDataToJson(StoryData instance) => <String, dynamic>{
      'filetype': instance.filetype,
      'url': instance.url,
      'fileTitle': instance.fileTitle,
      'expiryTime': StoryData._toJson(instance.expiryTime),
    };
