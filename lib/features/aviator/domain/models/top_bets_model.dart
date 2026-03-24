class TopBetsModel {
  final bool success;
  final List<TopBetsData> data;

  TopBetsModel({required this.success, required this.data});

  factory TopBetsModel.fromJson(Map<String, dynamic> json) => TopBetsModel(
    success: json["success"] ?? false,
    data: json["data"] == null
        ? []
        : List<TopBetsData>.from(
            json["data"].map((x) => TopBetsData.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class TopBetsData {
  final String? id;
  final RoundId? roundId;
  final UserId? userId;
  final num? stake;
  final String? currency;
  final num? autoCashout;
  final int? betIndex;
  final String? placedAt;
  final num? cashoutAt;
  final String? cashedOutAt;
  final num? payout;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  TopBetsData({
    this.id,
    this.roundId,
    this.userId,
    this.stake,
    this.currency,
    this.autoCashout,
    this.betIndex,
    this.placedAt,
    this.cashoutAt,
    this.cashedOutAt,
    this.payout,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory TopBetsData.fromJson(Map<String, dynamic> json) => TopBetsData(
    id: json["_id"],
    roundId: json["roundId"] != null ? RoundId.fromJson(json["roundId"]) : null,
    userId: json["userId"] != null ? UserId.fromJson(json["userId"]) : null,
    stake: json["stake"],
    currency: json["currency"],
    autoCashout: json["autoCashout"],
    betIndex: json["betIndex"],
    placedAt: json["placedAt"],
    cashoutAt: json["cashoutAt"],
    cashedOutAt: json["cashedOutAt"],
    payout: json["payout"],
    status: json["status"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'roundId': roundId?.toJson(),
    'userId': userId?.toJson(),
    'stake': stake,
    'currency': currency,
    'autoCashout': autoCashout,
    'betIndex': betIndex,
    'placedAt': placedAt,
    'cashoutAt': cashoutAt,
    'cashedOutAt': cashedOutAt,
    'payout': payout,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    '__v': v,
  };
}

class RoundId {
  final String? id;
  final int? seq;
  final String? state;
  final String? startedAt;
  final num? crashAt;
  final String? endedAt;
  RoundId({
    this.id,
    this.seq,
    this.state,
    this.startedAt,
    this.crashAt,
    this.endedAt,
  });

  factory RoundId.fromJson(Map<String, dynamic> json) => RoundId(
    id: json['_id'],
    seq: json['seq'],
    state: json['state'],
    startedAt: json['startedAt'],
    crashAt: json['crashAt'],
    endedAt: json['endedAt'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'seq': seq,
    'state': state,
    'startedAt': startedAt,
    'crashAt': crashAt,
    'endedAt': endedAt,
  };
}

class UserId {
  final String? id;
  final String? userName;
  final String? email;
  UserId({this.id, this.userName, this.email});

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
    id: json['_id'],
    userName: json['user_name'],
    email: json['email'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user_name': userName,
    'email': email,
  };
}
