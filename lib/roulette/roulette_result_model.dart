class RouletteResultModel {
  String? sId;
  String? marketId;
  String? marketName;
  String? tag;
  String? from;
  String? to;
  String? result;
  String? createdAt;
  String? updatedAt;
  String? declareTime;
  int? iV;

  RouletteResultModel(
      {this.sId,
      this.marketId,
      this.marketName,
      this.tag,
      this.from,
      this.to,
      this.result,
      this.declareTime,
      this.createdAt,
      this.updatedAt,
      this.iV});

  RouletteResultModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    marketId = json['market_id'];
    marketName = json['market_name'];
    tag = json['tag'];
    from = json['from'];
    to = json['to'];
    result = json['result'];
    declareTime = json['declare_time'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['market_id'] = marketId;
    data['market_name'] = marketName;
    data['tag'] = tag;
    data['from'] = from;
    data['to'] = to;
    data['result'] = result;
    data['declare_time'] = declareTime;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
}
}
