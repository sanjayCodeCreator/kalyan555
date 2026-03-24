import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sm_project/controller/apiservices/api_service.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/features/home/home_screen.dart' as main_app;

import '../tictactoe/presentation/screens/home_screen.dart';
import '../rockpaper_scissors/presentation/screens/rps_home_screen.dart';
import '../number_guessing/presentation/screens/ng_home_screen.dart';
import '../memory_match/presentation/screens/mm_home_screen.dart';
import '../sudoku/presentation/screens/sudoku_home_screen.dart';
import '../word_search/presentation/screens/ws_home_screen.dart';
import '../logic_grid_puzzle/presentation/screens/lgp_home_screen.dart';
import '../matchstick_puzzle/presentation/screens/mp_home_screen.dart';
import '../minesweeper/presentation/screens/ms_home_screen.dart';

Data? userData;

class GameInfo {
  final String title;
  final String subtitle;
  final String icon;
  final List<Color> colors;
  final Widget screen;

  GameInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.screen,
  });
}

/// Game selection screen with modern grid layout
class SelectGameScreen extends ConsumerStatefulWidget {
  const SelectGameScreen({super.key});

  @override
  ConsumerState<SelectGameScreen> createState() => _SelectGameScreenState();
}

class _SelectGameScreenState extends ConsumerState<SelectGameScreen> {
  bool isLoading = true;

  final List<GameInfo> games = [
    GameInfo(
      title: 'Tic Tac Toe',
      subtitle: 'Classic 3x3',
      icon: '⭕❌',
      colors: [const Color(0xFF6366F1), const Color(0xFF818CF8)],
      screen: const LocalGameHomeScreen(),
    ),
    GameInfo(
      title: 'Rock Paper',
      subtitle: 'Reflex Battle',
      icon: '🪨✂️',
      colors: [const Color(0xFFF43F5E), const Color(0xFFFB7185)],
      screen: const RPSHomeScreen(),
    ),
    GameInfo(
      title: 'Guess Number',
      subtitle: 'Find Secret',
      icon: '🎯🔢',
      colors: [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
      screen: const NGHomeScreen(),
    ),
    GameInfo(
      title: 'Memory Match',
      subtitle: 'Brain Train',
      icon: '🧠🃏',
      colors: [const Color(0xFFEC4899), const Color(0xFFF472B6)],
      screen: const MMHomeScreen(),
    ),
    GameInfo(
      title: 'Sudoku',
      subtitle: 'Logic Grid',
      icon: '📊🔢',
      colors: [const Color(0xFF06B6D4), const Color(0xFF22D3EE)],
      screen: const SudokuHomeScreen(),
    ),
    GameInfo(
      title: 'Word Search',
      subtitle: 'Find Words',
      icon: '🔍🔤',
      colors: [const Color(0xFF10B981), const Color(0xFF34D399)],
      screen: const WSHomeScreen(),
    ),
    GameInfo(
      title: 'Logic Grid',
      subtitle: 'Deduction',
      icon: '🧩💡',
      colors: [const Color(0xFFF59E0B), const Color(0xFFFBBF24)],
      screen: const LGPHomeScreen(),
    ),
    GameInfo(
      title: 'Matchstick',
      subtitle: 'Move Sticks',
      icon: '🔥🧩',
      colors: [const Color(0xFFEF4444), const Color(0xFFF87171)],
      screen: const MPHomeScreen(),
    ),
    GameInfo(
      title: 'Minesweeper',
      subtitle: 'Clear Field',
      icon: '💣💥',
      colors: [const Color(0xFF64748B), const Color(0xFF94A3B8)],
      screen: const MSHomeScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final response = await ApiService().getParticularUserData();
      if (!mounted) return;
      setState(() {
        userData = response?.data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6366F1)),
        ),
      );
    }

    if (userData?.betting == true) {
      return const main_app.HomeScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _GameCard(
                    game: games[index],
                    index: index,
                    onTap: () => _navigateToGame(context, games[index].screen),
                  );
                },
                childCount: games.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Center(
                child: Text(
                  'More games coming soon!',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF8FAFC),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${userData?.userName ?? "Player"}! 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'Game Zone',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: Color(0xFF6366F1)),
                      onPressed: _loadUserData,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final GameInfo game;
  final int index;
  final VoidCallback onTap;

  const _GameCard({
    required this.game,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: game.colors[0].withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Gradient Decoration
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        game.colors[0].withOpacity(0.2),
                        game.colors[1].withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: game.colors,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        game.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          game.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                )]  ),
                  ],
                ),
              ),
            ],
          ),
        ),                ),
        );
  }
}
