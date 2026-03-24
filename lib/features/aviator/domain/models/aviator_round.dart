//! State Model
class RoundState {
  final String? roundId;
  final String? seq;
  final String? state;
  final String? startedAt;
  final String? msRemaining;
  final String? endedAt;
  final String? crashAt;

  RoundState({
    this.roundId,
    this.seq,
    this.state,
    this.startedAt,
    this.msRemaining,
    this.endedAt,
    this.crashAt,
  });

  factory RoundState.fromJson(Map<String, dynamic> json) {
    return RoundState(
      roundId: json['roundId']?.toString(),
      seq: json['seq']?.toString(),
      state: json['state']?.toString(),
      startedAt: json['startedAt']?.toString(),
      msRemaining: json['msRemaining']?.toString(),
      endedAt: json['endedAt']?.toString(),
      crashAt: json['crashAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "roundId": roundId,
      "seq": seq,
      "state": state,
      "startedAt": startedAt,
      "msRemaining": msRemaining,
      "endedAt": endedAt,
      "crashAt": crashAt,
    };
  }
}

//! Tick Model
class Tick {
  final String? seq;
  final String? multiplier;
  final String? now;

  Tick({this.seq, this.multiplier, this.now});

  factory Tick.fromJson(Map<String, dynamic> json) {
    return Tick(
      seq: json['seq'].toString(),
      multiplier: json['multiplier'].toString(),
      now: json['now'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"seq": seq, "multiplier": multiplier, "now": now};
  }
}

//! Crash Model
class Crash {
  final String? roundId;
  final String? seq;
  final String? crashAt;

  Crash({this.roundId, this.seq, this.crashAt});

  factory Crash.fromJson(Map<String, dynamic> json) {
    return Crash(
      roundId: json['roundId'].toString(),
      seq: json['seq'].toString(),

      crashAt: json['crashAt'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {"roundId": roundId, "seq": seq, "crashAt": crashAt};
  }
}
