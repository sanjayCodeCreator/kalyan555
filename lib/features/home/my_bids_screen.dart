import 'package:sm_project/features/gali_desawar/gali_desawar_bid_history.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_bid_win_history.dart';
import 'package:sm_project/features/starline/starline_bid_history.dart';
import 'package:sm_project/features/starline/starline_win_history.dart';
import 'package:sm_project/utils/filecollection.dart';

class MyBidsScreen extends StatelessWidget {
  const MyBidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color background = Colors.white; // White background

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: darkBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Bids',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          children: [
            _MenuCard(
              icon: Icons.assessment_outlined,
              title: 'Game Bid History',
              subtitle: 'You can view your market bid history',
              iconColor: darkBlue,
              onTap: () => context.pushNamed(RouteNames.bids),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.timer_outlined,
              title: 'Game Result History',
              subtitle: 'You can view your game bid result history',
              iconColor: darkBlue,
              onTap: () => context.pushNamed(RouteNames.winbids),
            ),
            _MenuCard(
              icon: Icons.gamepad_outlined,
              title: 'Gali Desawar Bid History',
              subtitle: 'You can view your gali desawar bid history',
              iconColor: darkBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const GaliDesawarBidHistoryScreen(
                    tag: "galidisawar",
                  );
                },
              )),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.gamepad,
              title: 'Gali Desawar Win History',
              subtitle: 'You can view your gali desawar bid result history',
              iconColor: darkBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const GaliDesawarBidWinHistoryScreen(
                    tag: "galidisawar",
                  );
                },
              )),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.star_outline,
              title: 'Starline Bid History',
              subtitle: 'You can view your starline bid history',
              iconColor: darkBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const StarlineBidHistoryScreen();
                },
              )),
            ),
            const SizedBox(height: 16),
            _MenuCard(
              icon: Icons.star,
              title: 'Starline Win History',
              subtitle: 'You can view your starline bid result history',
              iconColor: darkBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const StarlineBidWinHistoryScreen();
                },
              )),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
