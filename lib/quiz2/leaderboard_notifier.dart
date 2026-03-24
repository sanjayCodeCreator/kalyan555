import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sm_project/utils/filecollection.dart';

// Leaderboard Entry Model
class LeaderboardEntryModel {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;
  final bool isTopThree;

  LeaderboardEntryModel({
    required this.rank,
    required this.name,
    required this.score,
    required this.isCurrentUser,
    required this.isTopThree,
  });

  LeaderboardEntryModel copyWith({
    int? rank,
    String? name,
    int? score,
    bool? isCurrentUser,
    bool? isTopThree,
  }) {
    return LeaderboardEntryModel(
      rank: rank ?? this.rank,
      name: name ?? this.name,
      score: score ?? this.score,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      isTopThree: isTopThree ?? this.isTopThree,
    );
  }
}

// Leaderboard State
class LeaderboardState {
  final bool isLoading;
  final String errorMessage;
  final List<LeaderboardEntryModel> entries;
  final String currentDay;
  final DateTime lastUpdated;
  final String? currentUserName;

  LeaderboardState({
    this.isLoading = false,
    this.errorMessage = '',
    this.entries = const [],
    required this.currentDay,
    required this.lastUpdated,
    this.currentUserName,
  });

  LeaderboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<LeaderboardEntryModel>? entries,
    String? currentDay,
    DateTime? lastUpdated,
    String? currentUserName,
  }) {
    return LeaderboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      entries: entries ?? this.entries,
      currentDay: currentDay ?? this.currentDay,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentUserName: currentUserName ?? this.currentUserName,
    );
  }
}

// Leaderboard Notifier
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier()
      : super(LeaderboardState(
          currentDay: _getCurrentDay(),
          lastUpdated: DateTime.now(),
        )) {
    loadLeaderboard();
  }

  // Indian names for the leaderboard
  static const List<String> indianFirstNames = [
    'Aarav',
    'Aditi',
    'Akash',
    'Ananya',
    'Arjun',
    'Avni',
    'Dhruv',
    'Diya',
    'Ishaan',
    'Kavya',
    'Krishna',
    'Lakshmi',
    'Manish',
    'Neha',
    'Om',
    'Priya',
    'Rahul',
    'Saanvi',
    'Sai',
    'Tara',
    'Varun',
    'Vidya',
    'Virat',
    'Zara',
    'Rohit',
    'Sachin',
    'Mahendra',
    'Ravindra',
    'Shikhar',
    'Jasprit',
    'Hardik',
    'Rishabh',
    'Ravichandran',
    'Ajinkya',
    'Bhuvneshwar',
    'Yuzvendra',
    'Kuldeep',
    'Shreyas',
    'Shubman',
    'Mohammed',
    'Deepak',
    'Shardul',
    'Suryakumar',
    'Axar',
    'Ishan',
    'Washington',
    'Navdeep',
    'Prithvi',
    'Aditya'
  ];

  static const List<String> indianLastNames = [
    'Sharma',
    'Patel',
    'Singh',
    'Kumar',
    'Gupta',
    'Joshi',
    'Trivedi',
    'Verma',
    'Agarwal',
    'Mehta',
    'Reddy',
    'Nair',
    'Pillai',
    'Iyer',
    'Mukherjee',
    'Chatterjee',
    'Banerjee',
    'Das',
    'Bose',
    'Shah',
    'Patil',
    'Desai',
    'Kapoor',
    'Malhotra',
    'Kohli',
    'Tendulkar',
    'Dhoni',
    'Jadeja',
    'Dhawan',
    'Bumrah',
    'Pandya',
    'Pant',
    'Ashwin',
    'Rahane',
    'Yadav',
    'Chahal',
    'Rao',
    'Kaur',
    'Goswami',
    'Mandhana',
    'Verma',
    'Krishnamurthy',
    'Gayakwad',
    'Pandey',
    'Shinde',
    'Waugh',
    'Kamra',
    'Prasad',
    'Khanna',
    'Mittal'
  ];

  // Get current day of the week
  static String _getCurrentDay() {
    final now = DateTime.now();
    final DateFormat formatter = DateFormat('EEEE');
    return formatter.format(now);
  }

  // Load leaderboard entries
  Future<void> loadLeaderboard() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: '');

      // Fetch current user data from API
      final userData = await ApiService().getParticularUserData();
      String? currentUserName;

      if (userData?.status == 'success' && userData?.data != null) {
        currentUserName = userData?.data?.userName;
      }

      // Get user's quiz points from local storage
      int? userQuizPoints = Prefs.getInt(PrefNames.quizPoints) ?? 0;

      // Check if we need to refresh based on day change
      final currentDay = _getCurrentDay();
      if (currentDay != state.currentDay ||
          state.entries.isEmpty ||
          currentUserName != state.currentUserName) {
        // Day has changed or we need to update with current user
        final entries = _generateLeaderboardEntries(
            currentDay, currentUserName, userQuizPoints);

        state = state.copyWith(
          isLoading: false,
          entries: entries,
          currentDay: currentDay,
          lastUpdated: DateTime.now(),
          currentUserName: currentUserName,
        );
      } else {
        // Same day, use cached entries
        state = state.copyWith(
          isLoading: false,
          currentUserName: currentUserName,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load leaderboard: ${e.toString()}',
      );
    }
  }

  // Get top entries for mini leaderboard display
  List<LeaderboardEntryModel> getTopEntries(int count) {
    // Ensure we have loaded entries
    if (state.entries.isEmpty) {
      loadLeaderboard();
      return [];
    }

    // Return top entries (up to count)
    return state.entries.take(count).toList();
  }

  // Generate random leaderboard entries with the current user included
  List<LeaderboardEntryModel> _generateLeaderboardEntries(
      String day, String? currentUserName, int userQuizPoints) {
    final random = Random();
    final List<LeaderboardEntryModel> entries = [];

    // Generate 25-30 random entries
    final entryCount = random.nextInt(6) + 25; // 25 to 30 entries

    // Generate random quiz points for other players (10 to 90 points)
    final List<int> randomScores = List.generate(
      entryCount,
      (_) => (random.nextInt(9) + 1) * 10, // 10, 20, ..., 90
    );

    // Sort scores in descending order
    randomScores.sort((a, b) => b.compareTo(a));

    // Check if user's points should be included
    bool includeUser = userQuizPoints > 0;
    int userRank = -1;

    // If we have user points, find where they should be ranked
    if (includeUser && currentUserName != null) {
      // Find the position where user's points should be inserted
      for (int i = 0; i < randomScores.length; i++) {
        if (userQuizPoints >= randomScores[i]) {
          userRank = i + 1;
          break;
        }
      }

      // If user's points are lower than all generated scores, place at the end
      if (userRank == -1 && randomScores.isNotEmpty) {
        userRank = randomScores.length + 1;
      }
    }

    // Generate entries with random names for non-user entries
    for (int i = 0; i < randomScores.length; i++) {
      // If we're at the user's rank position, insert the user first
      if (includeUser && userRank == i + 1) {
        entries.add(LeaderboardEntryModel(
          rank: i + 1,
          name: currentUserName ?? "You",
          score: userQuizPoints,
          isCurrentUser: true,
          isTopThree: i < 3,
        ));
        includeUser = false; // Mark user as already included
      }

      // Skip this position if we're going to exceed our entry count
      if (entries.length >= entryCount) break;

      // Generate a random name for this entry
      final firstName =
          indianFirstNames[random.nextInt(indianFirstNames.length)];
      final lastName = indianLastNames[random.nextInt(indianLastNames.length)];
      final fullName = '$firstName $lastName';

      entries.add(LeaderboardEntryModel(
        rank: entries.length + 1,
        name: fullName,
        score: randomScores[i],
        isCurrentUser: false,
        isTopThree: entries.length < 3,
      ));
    }

    // If user hasn't been added yet (ranks at the end), add them now
    if (includeUser && currentUserName != null) {
      entries.add(LeaderboardEntryModel(
        rank: entries.length + 1,
        name: currentUserName,
        score: userQuizPoints,
        isCurrentUser: true,
        isTopThree: entries.length < 3,
      ));
    }

    // Make sure all ranks are sequential
    for (int i = 0; i < entries.length; i++) {
      entries[i] = entries[i].copyWith(rank: i + 1);
    }

    return entries;
  }

  // Shuffle top 3 entries while maintaining their scores
  void shuffleTopThree() {
    if (state.entries.length < 3) return;

    final random = Random();
    final List<LeaderboardEntryModel> allEntries = List.from(state.entries);

    // Extract top 3
    final topThree = allEntries.take(3).toList();

    // Shuffle their names only
    final shuffledNames = topThree.map((e) => e.name).toList()..shuffle(random);

    // Reassign names but keep scores
    for (int i = 0; i < topThree.length; i++) {
      allEntries[i] = topThree[i].copyWith(name: shuffledNames[i]);
    }

    state = state.copyWith(entries: allEntries);
  }

  // Refresh the leaderboard (e.g., for testing or manual refresh)
  void refreshLeaderboard() {
    loadLeaderboard();
  }
}

// Provider for LeaderboardNotifier
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier();
});
