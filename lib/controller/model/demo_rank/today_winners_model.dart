class TodayWinnersModel {
  String? status;
  int? total;
  List<MarketWinner>? data;

  TodayWinnersModel({
    this.status,
    this.total,
    this.data,
  });

  TodayWinnersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'] is int
        ? json['total']
        : (json['total'] is String ? int.tryParse(json['total']) : null);
    if (json['data'] != null) {
      data = <MarketWinner>[];
      if (json['data'] is List) {
        for (var v in (json['data'] as List)) {
          if (v is Map<String, dynamic>) {
            data!.add(MarketWinner.fromJson(v));
          }
        }
      } else if (json['data'] is Map) {
        for (var v in (json['data'] as Map).values) {
          if (v is Map<String, dynamic>) {
            data!.add(MarketWinner.fromJson(v));
          }
        }
      }
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

class MarketWinner {
  String? marketId;
  String? marketName;
  String? tag;
  List<Winner>? winners;

  MarketWinner({
    this.marketId,
    this.marketName,
    this.tag,
    this.winners,
  });

  MarketWinner.fromJson(Map<String, dynamic> json) {
    marketId = json['market_id']?.toString();
    marketName = json['market_name']?.toString();
    tag = json['tag']?.toString();
    if (json['winners'] != null) {
      winners = <Winner>[];
      if (json['winners'] is List) {
        for (var v in (json['winners'] as List)) {
          if (v is Map<String, dynamic>) {
            winners!.add(Winner.fromJson(v));
          }
        }
      } else if (json['winners'] is Map) {
        for (var v in (json['winners'] as Map).values) {
          if (v is Map<String, dynamic>) {
            winners!.add(Winner.fromJson(v));
          }
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['market_id'] = marketId;
    data['market_name'] = marketName;
    data['tag'] = tag;
    if (winners != null) {
      data['winners'] = winners!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Winner {
  String? userName;
  int? win;
  int? position;

  Winner({
    this.userName,
    this.win,
    this.position,
  });

  Winner.fromJson(Map<String, dynamic> json) {
    userName = json['user_name']?.toString();
    win = json['win'] is int
        ? json['win']
        : (json['win'] is String ? int.tryParse(json['win']) : null);
    position = json['position'] is int
        ? json['position']
        : (json['position'] is String ? int.tryParse(json['position']) : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_name'] = userName;
    data['win'] = win;
    data['position'] = position;
    return data;
  }
}
