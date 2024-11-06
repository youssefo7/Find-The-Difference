import 'package:json_annotation/json_annotation.dart';

part 'game_template.g.dart';

enum ImageClicked {
  @JsonValue(null)
  swaggerGeneratedUnknown(null),

  @JsonValue('left')
  left('left'),
  @JsonValue('right')
  right('right');

  final String? value;

  const ImageClicked(this.value);
}

@JsonSerializable()
class Vec2 {
  final int x;
  final int y;

  Vec2({required this.x, required this.y});

  factory Vec2.fromJson(Map<String, dynamic> json) => _$Vec2FromJson(json);

  Map<String, dynamic> toJson() => _$Vec2ToJson(this);
}
