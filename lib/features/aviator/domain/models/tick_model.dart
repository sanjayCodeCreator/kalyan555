class Tick {
  final int seq;
  final double multiplier;
  final int now;

  Tick({required this.seq, required this.multiplier, required this.now});

  factory Tick.fromJson(Map<String, dynamic> json) {
    return Tick(
      seq: json['seq'] ?? 0,
      multiplier: (json['multiplier'] ?? 1.0).toDouble(),
      now: json['now'] ?? 0,
    );
  }
}
