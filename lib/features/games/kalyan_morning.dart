import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/game_list.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class KalyanMorning extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  final String? gameName;
  final String? currentTime;
  final String? balance;
  const KalyanMorning(
      {super.key,
      this.tag,
      this.marketId,
      this.marketName,
      this.gameName,
      this.balance,
      this.currentTime});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refRead = ref.read(kalyanMorningNotifierProvider.notifier);
    useEffect(() {
      ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel(context: context);
      refRead.getPermission();
      return;
    }, []);

    return Scaffold(
      backgroundColor: whiteBackgroundColor, // Light blue background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkBlue, // Using darkBlue from colors.dart
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          marketName?.toUpperCase() ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
              onTap: () {
                context.pushNamed(RouteNames.deposit);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(children: [
                  Image.asset(
                    walletLogo,
                    height: 30,
                    width: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Consumer(builder: (context, ref, child) {
                    final refWatch =
                        ref.watch(getParticularPlayerNotifierProvider).value;
                    return Text(
                        refWatch?.getParticularPlayerModel?.data?.wallet
                                .toString() ??
                            '0',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white));
                  })
                ]),
              )),
          const SizedBox(width: 8)
        ],
      ),
      body: SafeArea(child: SingleChildScrollView(
        child: Consumer(builder: (context, ref, child) {
          return gameGridView(context, ref);
        }),
      )),
    );
  }

  // Gold color for borders
  static const Color goldColor = Color(0xFFD9BC4C);

  // Categorize games into sections
  Map<String, List<Map>> categorizeGames(BuildContext context, WidgetRef ref) {
    final allGames =
        gamelist(context, ref, tag ?? "", marketId ?? "", marketName ?? "");

    Map<String, List<Map>> categorized = {
      'DIGITS': [],
      'PANNA': [],
      'MOTOR': [],
      'SANGAM': [],
    };

    for (var game in allGames) {
      final text = (game['text'] as String? ?? '').toLowerCase();
      if (text.contains('single digit') || text.contains('single digit bulk')) {
        categorized['DIGITS']!.add(game);
      } else if (text.contains('jodi') &&
          (text.contains('digit') || !text.contains('bulk'))) {
        categorized['DIGITS']!.add(game);
      } else if (text.contains('panna')) {
        categorized['PANNA']!.add(game);
      } else if (text.contains('motor') ||
          text == 'sp' ||
          text == 'dp' ||
          text == 'tp') {
        categorized['MOTOR']!.add(game);
      } else if (text.contains('sangam')) {
        categorized['SANGAM']!.add(game);
      } else if (text.contains('red') || text.contains('bracket')) {
        categorized['PANNA']!.add(game);
      } else if (text.contains('odd') || text.contains('even')) {
        categorized['PANNA']!.add(game);
      } else {
        // Default to PANNA if no match
        categorized['PANNA']!.add(game);
      }
    }

    // Remove empty categories
    categorized.removeWhere((key, value) => value.isEmpty);
    return categorized;
  }

  // Section Header
  Widget sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      color: darkBlue,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // Circular Game Button
  Widget gameButton(Map game) {
    final text = game['text'] as String? ?? '';
    // Split text into main and subtitle
    String mainText = text;
    String subtitle = '';

    final lowerText = text.toLowerCase();

    if (lowerText.contains('single digit')) {
      mainText = 'SINGLE';
      subtitle = 'DIGIT';
    } else if (lowerText.contains('jodi') && lowerText.contains('digit')) {
      mainText = 'JODI';
      subtitle = 'DIGIT';
    } else if (lowerText.contains('single panna')) {
      mainText = 'SINGLE';
      subtitle = 'PANNA';
    } else if (lowerText.contains('double panna')) {
      mainText = 'DOUBLE';
      subtitle = 'PANNA';
    } else if (lowerText.contains('triple panna')) {
      mainText = 'TRIPLE';
      subtitle = 'PANNA';
    } else if (lowerText.contains('sp motor') || lowerText.trim() == 'sp') {
      mainText = 'SP';
      subtitle = 'MOTOR';
    } else if (lowerText.contains('dp motor') || lowerText.trim() == 'dp') {
      mainText = 'DP';
      subtitle = 'MOTOR';
    } else if (lowerText.contains('tp motor') || lowerText.trim() == 'tp') {
      mainText = 'TP';
      subtitle = 'MOTOR';
    } else if (lowerText.contains('half sangam')) {
      mainText = 'HALF';
      subtitle = 'SANGAM';
    } else if (lowerText.contains('full sangam')) {
      mainText = 'FULL';
      subtitle = 'SANGAM';
    } else if (lowerText.contains('red bracket') ||
        lowerText.contains('red brak')) {
      mainText = 'RED';
      subtitle = 'BRAKET';
    } else if (lowerText.contains('odd') || lowerText.contains('even')) {
      mainText = text.toUpperCase();
      subtitle = '';
    } else {
      // For other games, try to split by space or use as is
      final words = text.split(' ');
      if (words.length >= 2) {
        mainText = words[0].toUpperCase();
        subtitle = words.sublist(1).join(' ').toUpperCase();
      } else {
        mainText = text.toUpperCase();
        subtitle = '';
      }
    }

    return InkWell(
      onTap: () => game['click'](),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (game['image'] != null)
              Image.asset(
                game['image'] as String,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 6),
            // Text(
            //   mainText.toUpperCase(),
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontSize: 13,
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 0.5,
            //   ),
            //   textAlign: TextAlign.center,
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            // ),
            // if (subtitle.isNotEmpty) ...[
            //   const SizedBox(height: 2),
            //   Text(
            //     subtitle.toUpperCase(),
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 10,
            //       fontWeight: FontWeight.w500,
            //       letterSpacing: 0.5,
            //     ),
            //     textAlign: TextAlign.center,
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // ],
          ],
        ),
      ),
    );
  }

  // Game Grid View with Sections
  Widget gameGridView(BuildContext context, WidgetRef ref) {
    final categorized = categorizeGames(context, ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ...categorized.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader(entry.key),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: entry.value.length <= 2
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: entry.value.map((game) {
                          return gameButton(game);
                        }).toList(),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: entry.value.length,
                        itemBuilder: (context, index) {
                          return Center(child: gameButton(entry.value[index]));
                        },
                      ),
              ),
              const SizedBox(height: 5),
            ],
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
