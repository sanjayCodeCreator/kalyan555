class BetResponse {
  final String roundId;
  final String userId;
  final int stake;
  final String currency;
  final int betIndex;
  final double? autoCashout;
  final String placedAt;
  final String? cashoutAt;
  final String? cashedOutAt;
  final double? payout;
  final String status;
  final String id;
  final String createdAt;
  final String updatedAt;

  BetResponse({
    required this.roundId,
    required this.userId,
    required this.stake,
    required this.currency,
    this.autoCashout,
    required this.betIndex,
    required this.placedAt,
    this.cashoutAt,
    this.cashedOutAt,
    this.payout,
    required this.status,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BetResponse.fromJson(Map<String, dynamic> json) {
    return BetResponse(
      roundId: json['roundId'],
      userId: json['userId'],
      stake: json['stake'],
      currency: json['currency'],
      autoCashout: (json['autoCashout'] as num?)?.toDouble(),
      betIndex: json['betIndex'],
      placedAt: json['placedAt'],
      cashoutAt: json['cashoutAt'],
      cashedOutAt: json['cashedOutAt'],
      payout: (json['payout'] as num?)?.toDouble(),
      status: json['status'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundId': roundId,
      'userId': userId,
      'stake': stake,
      'currency': currency,
      'autoCashout': autoCashout,
      'betIndex': betIndex,
      'placedAt': placedAt,
      'cashoutAt': cashoutAt,
      'cashedOutAt': cashedOutAt,
      'payout': payout,
      'status': status,
      '_id': id,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
