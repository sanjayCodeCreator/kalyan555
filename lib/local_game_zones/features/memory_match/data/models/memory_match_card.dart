import 'package:flutter/material.dart';

/// Represents the state of a single card
enum CardState {
  hidden, // Card is face down
  visible, // Card is flipped and showing
  matched, // Card has been matched
}

/// Represents a single card in the memory match game
class MemoryMatchCard {
  final int id; // Unique card id (0 to totalCards-1)
  final int pairId; // Pair identification (0 to totalPairs-1)
  final IconData icon; // Card face icon
  final Color color; // Card accent color
  CardState state; // Current state

  MemoryMatchCard({
    required this.id,
    required this.pairId,
    required this.icon,
    required this.color,
    this.state = CardState.hidden,
  });

  /// Create a copy with optional parameter overrides
  MemoryMatchCard copyWith({
    int? id,
    int? pairId,
    IconData? icon,
    Color? color,
    CardState? state,
  }) {
    return MemoryMatchCard(
      id: id ?? this.id,
      pairId: pairId ?? this.pairId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      state: state ?? this.state,
    );
  }

  /// Check if this card matches another card
  bool matchesWith(MemoryMatchCard other) {
    return pairId == other.pairId && id != other.id;
  }

  /// Check if card can be flipped
  bool get canFlip => state == CardState.hidden;

  /// Check if card is revealed (visible or matched)
  bool get isRevealed => state != CardState.hidden;

  @override
  String toString() => 'Card(id: $id, pairId: $pairId, state: $state)';
}

/// Available icons for card faces
class CardIcons {
  static const List<IconData> icons = [
    Icons.star,
    Icons.favorite,
    Icons.diamond,
    Icons.bolt,
    Icons.local_fire_department,
    Icons.pets,
    Icons.music_note,
    Icons.emoji_nature,
    Icons.sports_soccer,
    Icons.rocket_launch,
    Icons.cake,
    Icons.beach_access,
    Icons.directions_car,
    Icons.flight,
    Icons.anchor,
    Icons.palette,
    Icons.piano,
    Icons.extension,
  ];

  static const List<Color> colors = [
    Color(0xFFE91E63), // Pink
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF00E676), // Bright Green
    Color(0xFF651FFF), // Deep Purple Accent
    Color(0xFF00E5FF), // Cyan Accent
  ];
}
