import 'package:json_annotation/json_annotation.dart';

part 'next.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Next {
  //Next.blank();
  Next();
  factory Next.fromJson(Map<String, dynamic> json) => _$NextFromJson(json);
  //Next(this.one, this.two, this.three, this.four, this.total, this.max);
  Map<String, dynamic> toJson() => _$NextToJson(this);
  String one = '0';
  String two = '0';
  String three = '0';
  String four = '0';
  var total = 0;
  String max = '0';
}
