class GetBidsHistoryModel {
  String? status;
  Data? data;

  GetBidsHistoryModel({this.status, this.data});

  GetBidsHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? total;
  List<BetList>? betList;

  Data({this.total, this.betList});

  Data.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    if (json['bet_list'] != null) {
      betList = <BetList>[];
      json['bet_list'].forEach((v) {
        betList!.add(BetList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    if (betList != null) {
      data['bet_list'] = betList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BetList {
  String? sId;
  UserId? userId;
  String? gameMode;
  String? marketId;
  String? marketName;
  int? commission;
  String? session;
  String? openDigit;
  String? closeDigit;
  String? openPanna;
  String? closePanna;
  String? win;
  int? points;
  List<String>? result;
  String? tag;
  String? status;
  int? iV;
  String? createdAt;
  String? updatedAt;
  int? betAmount;
  int? winningAmount;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetList &&
          runtimeType == other.runtimeType &&
          sId == other.sId;

  @override
  int get hashCode => sId.hashCode;

  BetList(
      {this.sId,
      this.userId,
      this.gameMode,
      this.marketId,
      this.marketName,
      this.commission,
      this.session,
      this.openDigit,
      this.closeDigit,
      this.openPanna,
      this.closePanna,
      this.win,
      this.points,
      this.result,
      this.tag,
      this.status,
      this.iV,
      this.createdAt,
      this.updatedAt,
      this.betAmount,
      this.winningAmount});

  BetList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['user_id'] != null ? UserId.fromJson(json['user_id']) : null;
    gameMode = json['game_mode'];
    marketId = json['market_id'];
    marketName = json['market_name'];
    commission = json['commission'];
    session = json['session'];
    openDigit = json['open_digit'];
    closeDigit = json['close_digit'];
    openPanna = json['open_panna'];
    closePanna = json['close_panna'];
    win = json['win'];
    points = json['points'];
    result = json['result'].cast<String>();
    tag = json['tag'];
    status = json['status'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    betAmount = json['bet_amount'];
    winningAmount = json['winning_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['user_id'] = userId!.toJson();
    }
    data['game_mode'] = gameMode;
    data['market_id'] = marketId;
    data['market_name'] = marketName;
    data['commission'] = commission;
    data['session'] = session;
    data['open_digit'] = openDigit;
    data['close_digit'] = closeDigit;
    data['open_panna'] = openPanna;
    data['close_panna'] = closePanna;
    data['win'] = win;
    data['points'] = points;
    data['result'] = result;
    data['tag'] = tag;
    data['status'] = status;
    data['__v'] = iV;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['bet_amount'] = betAmount;
    data['winning_amount'] = winningAmount;
    return data;
  }
}

class UserId {
  String? sId;
  String? userName;
  String? mobile;
  bool? transactionPermanentlyBlocked;
  Null transactionBlockedUntil;

  UserId(
      {this.sId,
      this.userName,
      this.mobile,
      this.transactionPermanentlyBlocked,
      this.transactionBlockedUntil});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['user_name'];
    mobile = json['mobile'];
    transactionPermanentlyBlocked = json['transaction_permanently_blocked'];
    transactionBlockedUntil = json['transaction_blocked_until'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user_name'] = userName;
    data['mobile'] = mobile;
    data['transaction_permanently_blocked'] = transactionPermanentlyBlocked;
    data['transaction_blocked_until'] = transactionBlockedUntil;
    return data;
  }
}
