class GetMarketResultsModel {
  String? status;
  int? total;
  List<MarketResultModel>? data;
  String? message;

  GetMarketResultsModel({this.status, this.total, this.data, this.message});

  GetMarketResultsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'];
    message = json['message'];
    if (json['data'] != null) {
      data = <MarketResultModel>[];
      json['data'].forEach((v) {
        data!.add(MarketResultModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total'] = total;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MarketResultModel {
  String? sId;
  String? marketName;
  String? tag;
  String? from;
  String? to;
  String? openDigit;
  String? openPanna;
  String? closeDigit;
  String? closePanna;
  String? createdAt;
  String? updatedAt;
  int? iV;
  MarketId? marketId;

  MarketResultModel(
      {this.sId,
      this.marketName,
      this.tag,
      this.from,
      this.to,
      this.openDigit,
      this.openPanna,
      this.closeDigit,
      this.closePanna,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.marketId});

  MarketResultModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    marketName = json['market_name'];
    tag = json['tag'];
    from = json['from'];
    to = json['to'];
    openDigit = json['open_digit'];
    openPanna = json['open_panna'];
    closeDigit = json['close_digit'];
    closePanna = json['close_panna'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    marketId =
        json['market_id'] != null ? MarketId.fromJson(json['market_id']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['market_name'] = marketName;
    data['tag'] = tag;
    data['from'] = from;
    data['to'] = to;
    data['open_digit'] = openDigit;
    data['open_panna'] = openPanna;
    data['close_digit'] = closeDigit;
    data['close_panna'] = closePanna;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (marketId != null) {
      data['market_id'] = marketId!.toJson();
    }
    return data;
  }
}

class MarketId {
  String? marketId;
  String? name;
  String? nameHindi;
  String? openTime;
  String? closeTime;
  bool? status;
  String? tag;
  bool? marketStatus;
  String? createdAt;
  String? updatedAt;
  int? iV;

  MarketId(
      {this.marketId,
      this.name,
      this.nameHindi,
      this.openTime,
      this.closeTime,
      this.status,
      this.tag,
      this.marketStatus,
      this.createdAt,
      this.updatedAt,
      this.iV});

  MarketId.fromJson(Map<String, dynamic> json) {
    marketId = json['market_id'];
    name = json['name'];
    nameHindi = json['name_hindi'];
    openTime = json['open_time'];
    closeTime = json['close_time'];
    status = json['status'];
    tag = json['tag'];
    marketStatus = json['market_status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['market_id'] = marketId;
    data['name'] = name;
    data['name_hindi'] = nameHindi;
    data['open_time'] = openTime;
    data['close_time'] = closeTime;
    data['status'] = status;
    data['tag'] = tag;
    data['market_status'] = marketStatus;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
