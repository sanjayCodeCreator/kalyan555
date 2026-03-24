class BetRequest {
  final String roundId;
  final String userId;
  final int seq;
  final int stake;
  final double? autoCashout;
  final int betIndex;

  BetRequest({
    required this.roundId,
    required this.userId,
    required this.seq,
    required this.stake,
    this.autoCashout,
    required this.betIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      'roundId': roundId,
      'userId': userId,
      'seq': seq,
      'stake': stake,
      if (autoCashout != null) 'autoCashout': autoCashout,
      'betIndex': betIndex,
    };
  }
}
