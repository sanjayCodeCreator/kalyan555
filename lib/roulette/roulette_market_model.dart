import 'dart:developer';

class RouletteModel {
  String? sId;
  String? name;
  String? openTime;
  String? closeTime;
  bool? status;
  String? tag;
  int? iV;
  String? currentDate;
  String? currentTime;
  String? currentDay;

  RouletteModel(
      {this.sId,
      this.name,
      this.openTime,
      this.closeTime,
      this.status,
      this.tag,
      this.iV,
      this.currentDate,
      this.currentTime,
      this.currentDay});

  RouletteModel.fromJson(Map<String, dynamic> json) {
    log("${json['_id']}", name: 'roulette model');
    sId = json['_id'];
    name = json['name'];
    openTime = json['open_time'];
    closeTime = json['close_time'];
    status = json['status'];
    tag = json['tag'];
    iV = json['__v'];
    currentDate = json['current_date'];
    currentTime = json['current_time'];
    currentDay = json['current_day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['open_time'] = openTime;
    data['close_time'] = closeTime;
    data['status'] = status;
    data['tag'] = tag;
    data['__v'] = iV;
    data['current_date'] = currentDate;
    data['current_time'] = currentTime;
    data['current_day'] = currentDay;
    return data;
  }
}
