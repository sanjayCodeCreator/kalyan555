class GetAllMarketModel {
  String? status;
  String? message;
  int? total;
  List<Data>? data;

  GetAllMarketModel({this.status, this.message, this.total, this.data});

  GetAllMarketModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  MarketOffDay? marketOffDay;
  String? sId;
  String? name;
  String? nameHindi;
  String? openTime;
  String? closeTime;
  bool? status;
  String? openDigit;
  String? closeDigit;
  String? openPanna;
  String? closePanna;
  String? tag;
  bool? marketStatus;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.marketOffDay,
      this.sId,
      this.name,
      this.nameHindi,
      this.openTime,
      this.closeTime,
      this.status,
      this.openDigit,
      this.closeDigit,
      this.openPanna,
      this.closePanna,
      this.tag,
      this.marketStatus,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    marketOffDay = json['market_off_day'] != null
        ? MarketOffDay.fromJson(json['market_off_day'])
        : null;
    sId = json['_id'];
    name = json['name'];
    nameHindi = json['name_hindi'];
    openTime = json['open_time'];
    closeTime = json['close_time'];
    status = json['status'];
    openDigit = json['open_digit'];
    closeDigit = json['close_digit'];
    openPanna = json['open_panna'];
    closePanna = json['close_panna'];
    tag = json['tag'];
    marketStatus = json['market_status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (marketOffDay != null) {
      data['market_off_day'] = marketOffDay!.toJson();
    }
    data['_id'] = sId;
    data['name'] = name;
    data['name_hindi'] = nameHindi;
    data['open_time'] = openTime;
    data['close_time'] = closeTime;
    data['status'] = status;
    data['open_digit'] = openDigit;
    data['close_digit'] = closeDigit;
    data['open_panna'] = openPanna;
    data['close_panna'] = closePanna;
    data['tag'] = tag;
    data['market_status'] = marketStatus;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class MarketOffDay {
  bool? monday;
  bool? tuesday;
  bool? wednesday;
  bool? thursday;
  bool? friday;
  bool? saturday;
  bool? sunday;

  MarketOffDay(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday});

  MarketOffDay.fromJson(Map<String, dynamic> json) {
    monday = json['monday'];
    tuesday = json['tuesday'];
    wednesday = json['wednesday'];
    thursday = json['thursday'];
    friday = json['friday'];
    saturday = json['saturday'];
    sunday = json['sunday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['monday'] = monday;
    data['tuesday'] = tuesday;
    data['wednesday'] = wednesday;
    data['thursday'] = thursday;
    data['friday'] = friday;
    data['saturday'] = saturday;
    data['sunday'] = sunday;
    return data;
  }
}
