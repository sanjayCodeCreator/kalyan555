class Rounds {
  final Stats stats;
  final String id;
  final int seq;
  final String state;
  final String startedAt;
  final String serverSeedHash;
  final int nonce;
  final String createdAt;
  final String updatedAt;
  final int v;
  final double? crashAt;
  final String? endedAt;

  Rounds({
    required this.stats,
    required this.id,
    required this.seq,
    required this.state,
    required this.startedAt,
    required this.serverSeedHash,
    required this.nonce,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.crashAt,
    this.endedAt,
  });

  factory Rounds.fromJson(Map<String, dynamic> json) => Rounds(
    stats: Stats.fromJson(json["stats"]),
    id: json["_id"],
    seq: json["seq"],
    state: json["state"],
    startedAt: json["startedAt"],
    serverSeedHash: json["serverSeedHash"],
    nonce: json["nonce"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    crashAt: json["crashAt"]?.toDouble(),
    endedAt: json["endedAt"],
  );

  Map<String, dynamic> toJson() => {
    "stats": stats.toJson(),
    "_id": id,
    "seq": seq,
    "state": state,
    "startedAt": startedAt,
    "serverSeedHash": serverSeedHash,
    "nonce": nonce,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "crashAt": crashAt,
    "endedAt": endedAt,
  };
}

class Stats {
  final int bets;
  final int players;
  final double maxCashout;

  Stats({required this.bets, required this.players, required this.maxCashout});

  factory Stats.fromJson(Map<String, dynamic> json) => Stats(
    bets: json["bets"],
    players: json["players"],
    maxCashout: json["maxCashout"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "bets": bets,
    "players": players,
    "maxCashout": maxCashout,
  };
}
