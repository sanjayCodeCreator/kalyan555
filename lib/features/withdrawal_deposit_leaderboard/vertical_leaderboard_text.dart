import 'package:sm_project/features/withdrawal_deposit_leaderboard/withdrawal_deposit_leaderboard_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

enum TextCycleFilter { all, withdrawal, deposit }

class TextCycleWidget extends ConsumerWidget {
  const TextCycleWidget({super.key, this.filter = TextCycleFilter.all});

  final TextCycleFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardState =
        ref.watch(withdrawalDepositLeaderboardNotifierProvider);

    return leaderboardState.when(
      data: (state) {
        // If messages are empty, show a placeholder
        if (state.messages.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 14.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  darkBlue,
                  darkBlue,
                  darkBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                filter == TextCycleFilter.withdrawal
                    ? Image.asset('assets/images/withdrawal.png',
                        width: 20, height: 20)
                    : Image.asset('assets/images/deposit.png',
                        width: 20, height: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Loading transactions...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Filter messages based on the required view
        final List<String> filtered = () {
          if (filter == TextCycleFilter.withdrawal) {
            return state.messages
                .where((m) => m.contains('withdrew') || m.contains('💸'))
                .toList();
          }
          if (filter == TextCycleFilter.deposit) {
            return state.messages
                .where((m) => m.contains('deposited') || m.contains('💰'))
                .toList();
          }
          return state.messages;
        }();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14.0),
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                darkBlue,
                darkBlue.withOpacity(0.7),
                darkBlue.withOpacity(0.7),
                darkBlue,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              filter == TextCycleFilter.withdrawal
                  ? Image.asset('assets/images/withdrawal2.png',
                      width: 25, height: 25)
                  : Image.asset('assets/images/deposit2.png',
                      width: 25, height: 25),
              const SizedBox(width: 2),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.8), // Start above
                      end: const Offset(0, 0), // Slide into view
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuad,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  ),
                  child: (filtered.isEmpty)
                      ? const Text(
                          'No recent activity',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          filtered[state.currentIndex % filtered.length],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          key: ValueKey(state.currentIndex),
                          style: const TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14.0),
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.purple.shade600,
              Colors.deepPurple.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 16),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 14.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.purple.shade600,
              Colors.deepPurple.shade700,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 16),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Check transactions...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
