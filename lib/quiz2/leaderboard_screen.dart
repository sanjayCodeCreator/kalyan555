// import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/quiz2/leaderboard_notifier.dart';
import 'package:sm_project/quiz2/quiz_notifier.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _animationController.forward();

    // Start confetti when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      _playCheeringSound();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Stop audio when app goes to background
      _audioPlayer.stop();
    }
  }

  Future<void> _playCheeringSound() async {
    try {
      await _audioPlayer.setSource(AssetSource('sound/cheering_crowd.wav'));
      await _audioPlayer.resume();

      // Stop the audio after 8 seconds
      Future.delayed(const Duration(seconds: 7), () {
        if (mounted) {
          _audioPlayer.stop();
        }
      });
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _scrollController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _refreshLeaderboard() async {
    setState(() {
      _isRefreshing = true;
    });

    // Perform the refresh
    ref.read(leaderboardProvider.notifier).refreshLeaderboard();

    // Add a delay to make the refresh indicator visible for a moment
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaderboardState = ref.watch(leaderboardProvider);
    final quizState = ref.watch(quizProvider);
    final currentDay = leaderboardState.currentDay;
    final lastUpdated = leaderboardState.lastUpdated;
    final formattedLastUpdate =
        DateFormat('dd MMM yyyy, hh:mm a').format(lastUpdated);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    // Get quiz points if available
    int quizPoints = 0;
    if (quizState.result != null) {
      quizPoints = quizState.result!.points;
    }

    return WillPopScope(
      onWillPop: () async {
        // Stop audio when navigating back
        await _audioPlayer.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xff011005),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Leaderboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 24 : 20,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
              onPressed: _refreshLeaderboard,
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: Colors.white, size: isTablet ? 28 : 24),
            onPressed: () {
              // Stop audio when back button is pressed
              _audioPlayer.stop();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff142318),
                    Color(0xff011005),
                  ],
                ),
              ),
              child: leaderboardState.isLoading || _isRefreshing
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xfffeb800),
                      ),
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          // Today's date and current day header
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                20, isTablet ? 16 : 8, 20, isTablet ? 8 : 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentDay,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Last updated: $formattedLastUpdate",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fade(duration: 500.ms, delay: 100.ms)
                                .slideY(
                                    begin: -0.2,
                                    end: 0,
                                    duration: 500.ms,
                                    curve: Curves.easeOutQuad),
                          ),

                          SizedBox(height: isTablet ? 12 : 8),

                          // Display quiz points if available
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: isTablet ? 40.0 : 20.0,
                                vertical: isTablet ? 12.0 : 8.0),
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 16.0 : 12.0,
                                vertical: isTablet ? 12.0 : 8.0),
                            decoration: BoxDecoration(
                              color: const Color(0xfffeb800).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xfffeb800),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Your Highest Quiz Points',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 16 : 14,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: const Color(0xfffeb800),
                                          size: isTablet ? 24 : 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${Prefs.getInt(PrefNames.quizPoints) ?? 0} pts',
                                          style: TextStyle(
                                            color: const Color(0xfffeb800),
                                            fontWeight: FontWeight.bold,
                                            fontSize: isTablet ? 20 : 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (leaderboardState.currentUserName != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.person,
                                            color: Colors.white70,
                                            size: isTablet ? 16 : 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          leaderboardState.currentUserName!,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: isTablet ? 14 : 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          )
                              .animate()
                              .fade(duration: 500.ms, delay: 200.ms)
                              .slideX(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 500.ms,
                                  curve: Curves.easeOutQuad),

                          // Top 3 leaderboard positions
                          if (leaderboardState.entries.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 40.0 : 20.0),
                              child: _buildTop3Podium(
                                  leaderboardState.entries, isTablet),
                            ),

                          SizedBox(height: isTablet ? 24 : 16),

                          // Divider with "All Players" text
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 40.0 : 20.0),
                            child: Row(
                              children: [
                                Text(
                                  "All Players",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            )
                                .animate()
                                .fade(duration: 500.ms, delay: 300.ms)
                                .slideX(begin: -0.2, end: 0, duration: 500.ms),
                          ),

                          SizedBox(height: isTablet ? 12 : 8),

                          // List of all entries
                          Expanded(
                            child: RefreshIndicator(
                              color: const Color(0xfffeb800),
                              backgroundColor: const Color(0xff142318),
                              onRefresh: _refreshLeaderboard,
                              child: ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 40 : 20),
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: leaderboardState.entries.length,
                                itemBuilder: (context, index) {
                                  final entry = leaderboardState.entries[index];

                                  // Calculate points to display - use quiz points for current user if available
                                  int pointsToDisplay = entry.score;
                                  if (entry.isCurrentUser && quizPoints > 0) {
                                    pointsToDisplay = quizPoints;
                                  }

                                  // Return without the animations that cause scrolling issues
                                  return LeaderboardEntry(
                                    rank: entry.rank,
                                    name: entry.name,
                                    score: pointsToDisplay,
                                    isCurrentUser: entry.isCurrentUser,
                                    isTop5: entry.rank <= 5,
                                    isTablet: isTablet,
                                    index: index,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: math.pi / 2,
                maxBlastForce: 5,
                minBlastForce: 1,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.1,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Color(0xfffeb800),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop3Podium(List<LeaderboardEntryModel> entries, bool isTablet) {
    if (entries.length < 3) return const SizedBox.shrink();

    // Get quiz points if available
    final quizState = ref.watch(quizProvider);
    int quizPoints = 0;
    if (quizState.result != null) {
      quizPoints = quizState.result!.points;
    }

    // Adjust height based on screen size - reduce height for smaller screens
    return SizedBox(
      height: isTablet ? 260 : 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Second place
              _buildPodiumItem(
                entries[1],
                Colors.grey.shade300,
                const Color(0xff2A2A2A),
                height: isTablet ? 180 : 120,
                delayMs: 200,
                isTablet: isTablet,
                quizPoints: quizPoints,
              ),

              // First place
              _buildPodiumItem(
                entries[0],
                const Color(0xFFFFD700), // Gold
                const Color(0xff3A3A00),
                height: isTablet ? 220 : 140,
                delayMs: 0,
                hasCrown: true,
                isTablet: isTablet,
                quizPoints: quizPoints,
              ),

              // Third place
              _buildPodiumItem(
                entries[2],
                const Color(0xFFCD7F32), // Bronze
                const Color(0xff3A2A00),
                height: isTablet ? 140 : 90,
                delayMs: 400,
                isTablet: isTablet,
                quizPoints: quizPoints,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(
    LeaderboardEntryModel entry,
    Color color,
    Color shadowColor, {
    required double height,
    required int delayMs,
    bool hasCrown = false,
    bool isTablet = false,
    int quizPoints = 0,
  }) {
    // Use quiz points for this entry if it's the current user and points are available
    int pointsToDisplay = entry.score;
    if (entry.isCurrentUser && quizPoints > 0) {
      pointsToDisplay = quizPoints;
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name and score
              Container(
                constraints: BoxConstraints(maxWidth: isTablet ? 120 : 80),
                child: Text(
                  entry.name,
                  style: TextStyle(
                    color: entry.isCurrentUser
                        ? const Color(0xfffeb800)
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 16 : 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "$pointsToDisplay pts",
                style: TextStyle(
                  color: entry.isCurrentUser ? const Color(0xfffeb800) : color,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 18 : 14,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isTablet ? 14 : 15),

              // Avatar with crown if first place
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (hasCrown)
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: Icon(
                        Icons.emoji_events,
                        color: const Color(0xFFFFD700),
                        size: isTablet ? 28 : 20,
                      ),
                    ),
                  CircleAvatar(
                    radius: isTablet ? 30 : 20,
                    backgroundColor:
                        entry.isCurrentUser ? const Color(0xfffeb800) : color,
                    child: Text(
                      '${entry.rank}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 24 : 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isTablet ? 8 : 4),

              // Podium stand
              Container(
                height: height,
                width: isTablet ? 80 : 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: entry.isCurrentUser
                        ? [
                            const Color(0xfffeb800),
                            const Color(0xffe29000),
                          ]
                        : [
                            color,
                            shadowColor,
                          ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isTablet ? 8 : 4),
                    topRight: Radius.circular(isTablet ? 8 : 4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fade(duration: 800.ms, delay: delayMs.ms)
            .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
                delay: delayMs.ms)
            .slideY(
                begin: 0.2,
                end: 0,
                duration: 500.ms,
                delay: delayMs.ms,
                curve: Curves.elasticOut),
      ),
    );
  }
}

class LeaderboardEntry extends StatefulWidget {
  final int rank;
  final String name;
  final int score;
  final bool isCurrentUser;
  final bool isTop5;
  final bool isTablet;
  final int index;

  const LeaderboardEntry({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.isCurrentUser,
    this.isTop5 = false,
    this.isTablet = false,
    this.index = 0,
  });

  @override
  State<LeaderboardEntry> createState() => _LeaderboardEntryState();
}

class _LeaderboardEntryState extends State<LeaderboardEntry> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Skip the first 3 entries as they're shown in the podium
    // But only in the main leaderboard screen, not in the mini version
    if (Navigator.of(context).canPop() && widget.rank <= 3)
      return const SizedBox.shrink();

    final bool shouldHighlight = widget.isCurrentUser || widget.isTop5;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isHovered = !_isHovered;
          // Reset hover state after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _isHovered = false;
              });
            }
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: widget.isTablet ? 12 : 8),
        padding: EdgeInsets.symmetric(
            horizontal: widget.isTablet ? 24 : 16,
            vertical: widget.isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? (widget.isCurrentUser
                  ? const Color(0xfffeb800).withOpacity(0.25)
                  : widget.isTop5
                      ? Colors.black45
                      : Colors.black38)
              : widget.isCurrentUser
                  ? const Color(0xfffeb800).withOpacity(0.2)
                  : widget.isTop5
                      ? Colors.black38
                      : widget.rank % 2 == 0
                          ? Colors.black26
                          : Colors.black12,
          borderRadius: BorderRadius.circular(widget.isTablet ? 15 : 10),
          border: shouldHighlight
              ? Border.all(
                  color: widget.isCurrentUser
                      ? const Color(0xfffeb800)
                      : Colors.white.withOpacity(0.5),
                  width: widget.isTablet ? 1.5 : 1)
              : null,
          boxShadow: shouldHighlight
              ? [
                  BoxShadow(
                    color: widget.isCurrentUser
                        ? const Color(0xfffeb800)
                            .withOpacity(_isHovered ? 0.3 : 0.2)
                        : Colors.white.withOpacity(_isHovered ? 0.15 : 0.1),
                    blurRadius: widget.isTablet ? 12 : 8,
                    spreadRadius: widget.isTablet ? 2 : 1,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            // Rank container
            Container(
              width: widget.isTablet ? 40 : 30,
              height: widget.isTablet ? 40 : 30,
              decoration: BoxDecoration(
                color: _getRankColor(),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${widget.rank}',
                  style: TextStyle(
                    color: widget.rank <= 5 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isTablet ? 18 : 14,
                  ),
                ),
              ),
            ),
            SizedBox(width: widget.isTablet ? 16 : 12),

            // Profile pic placeholder (using first letter of name)
            Container(
              width: widget.isTablet ? 48 : 36,
              height: widget.isTablet ? 48 : 36,
              decoration: BoxDecoration(
                color: _getProfileColor(),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.name.isNotEmpty ? widget.name[0] : '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isTablet ? 24 : 18,
                  ),
                ),
              ),
            ),
            SizedBox(width: widget.isTablet ? 16 : 12),

            // Name and points
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isTablet ? 16 : 14,
                      fontWeight:
                          shouldHighlight ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.isCurrentUser)
                    Text(
                      'You',
                      style: TextStyle(
                        color: const Color(0xfffeb800),
                        fontSize: widget.isTablet ? 14 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // Score
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: widget.isTablet ? 16 : 12,
                  vertical: widget.isTablet ? 6 : 4),
              decoration: BoxDecoration(
                color: widget.isCurrentUser
                    ? const Color(0xfffeb800)
                    : widget.isTop5
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${widget.score} pts',
                style: TextStyle(
                  color: widget.isCurrentUser ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: widget.isTablet ? 16 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor() {
    if (widget.rank == 1) return Colors.amber;
    if (widget.rank == 2) return Colors.grey.shade300;
    if (widget.rank == 3) return Colors.brown.shade300;
    if (widget.rank == 4) return const Color(0xFF7FFFD4); // Aquamarine
    if (widget.rank == 5) return const Color(0xFFE6E6FA); // Lavender
    return Colors.transparent;
  }

  Color _getProfileColor() {
    // Generate a consistent color based on the name
    if (widget.isCurrentUser) return const Color(0xfffeb800).withOpacity(0.8);
    if (widget.isTop5) return Colors.teal.withOpacity(0.8);

    final hash = widget.name.hashCode;
    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = hash & 0x0000FF;

    return Color.fromRGBO(r < 100 ? r + 100 : r, g < 100 ? g + 100 : g,
        b < 100 ? b + 100 : b, 1.0);
  }
}
