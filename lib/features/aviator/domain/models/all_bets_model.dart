class AllBetsModel {
  final String roundId;
  final List<BetModel> bets;
  final int count;

  AllBetsModel({
    required this.roundId,
    required this.bets,
    required this.count,
  });

  factory AllBetsModel.fromJson(Map<String, dynamic> json) {
    return AllBetsModel(
      roundId: json['roundId'],
      bets: (json['bets'] as List<dynamic>)
          .map((e) => BetModel.fromJson(e))
          .toList(),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundId': roundId,
      'bets': bets.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

class BetModel {
  final String id;
  final String roundId;
  final User userId;
  final User user;
  final double stake;
  final double? autoCashout;
  final double? cashoutAt;
  final double payout;
  final String status;
  final int betIndex;
  final DateTime createdAt;
  final DateTime? cashedOutAt;

  BetModel({
    required this.id,
    required this.roundId,
    required this.userId,
    required this.user,
    required this.stake,
    this.autoCashout,
    this.cashoutAt,
    required this.payout,
    required this.status,
    required this.betIndex,
    required this.createdAt,
    this.cashedOutAt,
  });

  factory BetModel.fromJson(Map<String, dynamic> json) {
    return BetModel(
      id: json['_id'],
      roundId: json['roundId'],
      userId: User.fromJson(json['userId']),
      user: User.fromJson(json['user']),
      stake: (json['stake'] ?? 0).toDouble(),
      autoCashout: (json['autoCashout'] != null)
          ? (json['autoCashout'] as num).toDouble()
          : 0.0,
      cashoutAt: (json['cashoutAt'] != null)
          ? (json['cashoutAt'] as num).toDouble()
          : 0.0,
      payout: (json['payout'] ?? 0).toDouble(),
      status: json['status'],
      betIndex: json['betIndex'],
      createdAt: DateTime.parse(json['createdAt']),
      cashedOutAt: json['cashedOutAt'] != null
          ? DateTime.tryParse(json['cashedOutAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'roundId': roundId,
      'userId': userId.toJson(),
      'user': user.toJson(),
      'stake': stake,
      'autoCashout': autoCashout,
      'cashoutAt': cashoutAt,
      'payout': payout,
      'status': status,
      'betIndex': betIndex,
      'createdAt': createdAt.toIso8601String(),
      'cashedOutAt': cashedOutAt?.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String userName;

  User({required this.id, required this.userName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['_id'], userName: json['user_name']);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'user_name': userName};
  }
}
