import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'story_data.g.dart';

@JsonSerializable(explicitToJson: true)
class StoryData {
  String? filetype;
  Map<String, String?>? url;
  Map<String, String?>? fileTitle;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  DateTime? expiryTime;

  StoryData({this.filetype, this.url});

  factory StoryData.fromJson(Map<String, dynamic> json) =>
      _$StoryDataFromJson(json);
  Map<String, dynamic> toJson() => _$StoryDataToJson(this);
  static DateTime? _fromJson(Timestamp? timestamp) => timestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch)
      : null;
  static Timestamp? _toJson(DateTime? time) => time != null
      ? Timestamp.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch)
      : null;
}
