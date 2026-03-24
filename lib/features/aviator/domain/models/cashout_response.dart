class CashoutResponse {
  final String id;
  final String roundId;
  final String userId;
  final int stake;
  final String currency;
  final double? autoCashout;
  final int betIndex;
  final String placedAt;
  final double? cashoutAt;
  final String? cashedOutAt;
  final double? payout;
  final String status;
  final String createdAt;
  final String updatedAt;
  final int v;

  CashoutResponse({
    required this.id,
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
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory CashoutResponse.fromJson(Map<String, dynamic> json) {
    return CashoutResponse(
      id: json['_id']?.toString() ?? '',
      roundId: json['roundId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      stake: (json['stake'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      autoCashout: json['autoCashout'] != null
          ? (json['autoCashout'] as num).toDouble()
          : null,
      betIndex: (json['betIndex'] as num?)?.toInt() ?? 0,
      placedAt: json['placedAt']?.toString() ?? '',
      cashoutAt: json['cashoutAt'] != null
          ? (json['cashoutAt'] as num).toDouble()
          : null,
      cashedOutAt: json['cashedOutAt']?.toString(),
      payout:
          json['payout'] != null ? (json['payout'] as num).toDouble() : null,
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      v: (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "roundId": roundId,
      "userId": userId,
      "stake": stake,
      "currency": currency,
      "autoCashout": autoCashout,
      "betIndex": betIndex,
      "placedAt": placedAt,
      "cashoutAt": cashoutAt,
      "cashedOutAt": cashedOutAt,
      "payout": payout,
      "status": status,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "__v": v,
    };
  }
}
