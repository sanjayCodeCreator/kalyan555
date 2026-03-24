class RouletteBidModel {
  String? sId;
  String? user;
  String? gameMode;
  String? market;
  String? marketName;
  String? digit1;
  String? digit2;
  String? digit3;
  String? win;
  int? betAmount;
  int? winningAmount;
  int? points;
  String? result;
  String? tag;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  RouletteBidModel(
      {this.sId,
      this.user,
      this.gameMode,
      this.market,
      this.marketName,
      this.digit1,
      this.digit2,
      this.digit3,
      this.betAmount,
      this.winningAmount,
      this.win,
      this.points,
      this.result,
      this.tag,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV});

  RouletteBidModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'];
    gameMode = json['game_mode'];
    market = json['market'];
    marketName = json['market_name'];
    digit1 = json['digit_1'];
    digit2 = json['digit_2'];
    digit3 = json['digit_3'];
    win = json['win'];
    betAmount = json['bet_amount'];
    winningAmount = json['winning_amount'];
    points = json['points'];
    result = json['result'];
    tag = json['tag'];
    status = json['status'];

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user'] = user;
    data['game_mode'] = gameMode;
    data['market'] = market;
    data['market_name'] = marketName;
    data['digit_1'] = digit1;
    data['digit_2'] = digit2;
    data['digit_3'] = digit3;
    data['win'] = win;
    data['bet_amount'] = betAmount;
    data['winning_amount'] = winningAmount;
    data['points'] = points;
    data['result'] = result;
    data['tag'] = tag;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;

    data['__v'] = iV;
    return data;
  }
}
