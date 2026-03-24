class GetAllResultModel {
  String? status;
  int? total;
  List<Data>? data;

  GetAllResultModel({this.status, this.total, this.data});

  GetAllResultModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
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
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? market;
  String? marketCollection;
  String? marketName;
  String? tag;
  String? from;
  String? to;
  String? openDeclare;
  String? openResult;
  String? createdAt;
  String? updatedAt;
  int? iV;
  MarketDetails? marketDetails;
  String? id;

  Data(
      {this.sId,
      this.market,
      this.marketCollection,
      this.marketName,
      this.tag,
      this.from,
      this.to,
      this.openDeclare,
      this.openResult,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.marketDetails,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    market = json['market'];
    marketCollection = json['market_collection'];
    marketName = json['market_name'];
    tag = json['tag'];
    from = json['from'];
    to = json['to'];
    openDeclare = json['open_declare'];
    openResult = json['open_result'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    marketDetails = json['market_details'] != null
        ? MarketDetails.fromJson(json['market_details'])
        : null;
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['market'] = market;
    data['market_collection'] = marketCollection;
    data['market_name'] = marketName;
    data['tag'] = tag;
    data['from'] = from;
    data['to'] = to;
    data['open_declare'] = openDeclare;
    data['open_result'] = openResult;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (marketDetails != null) {
      data['market_details'] = marketDetails!.toJson();
    }
    data['id'] = id;
    return data;
  }
}

class MarketDetails {
  String? sId;
  String? name;
  String? gameOrder;
  String? openTime;
  String? close1;
  String? close1Max;
  String? close2;
  String? close2Max;
  String? resultTime;
  bool? status;
  String? openDigit;
  String? closeDigit;
  String? tag;
  bool? marketStatus;
  int? iV;

  MarketDetails(
      {this.sId,
      this.name,
      this.gameOrder,
      this.openTime,
      this.close1,
      this.close1Max,
      this.close2,
      this.close2Max,
      this.resultTime,
      this.status,
      this.openDigit,
      this.closeDigit,
      this.tag,
      this.marketStatus,
      this.iV});

  MarketDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    gameOrder = json['game_order'];
    openTime = json['open_time'];
    close1 = json['close_1'];
    close1Max = json['close1_max'];
    close2 = json['close_2'];
    close2Max = json['close2_max'];
    resultTime = json['result_time'];
    status = json['status'];
    openDigit = json['open_digit'];
    closeDigit = json['close_digit'];
    tag = json['tag'];
    marketStatus = json['market_status'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['game_order'] = gameOrder;
    data['open_time'] = openTime;
    data['close_1'] = close1;
    data['close1_max'] = close1Max;
    data['close_2'] = close2;
    data['close2_max'] = close2Max;
    data['result_time'] = resultTime;
    data['status'] = status;
    data['open_digit'] = openDigit;
    data['close_digit'] = closeDigit;
    data['tag'] = tag;
    data['market_status'] = marketStatus;
    data['__v'] = iV;
    return data;
  }
}
