import 'package:sm_project/features/card_jackpot/jackpot_history_switch_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class JackpotHistoryComponent extends StatelessWidget {
  const JackpotHistoryComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final refRead =
                    ref.read(jackpotHistorySwitchNotifierProvider.notifier);
                final refWatch =
                    ref.watch(jackpotHistorySwitchNotifierProvider);
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: refWatch == "Game History"
                        ? darkBlue
                        : const Color(0xffEAEAEA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    refRead.updateSelection("Game History");
                  },
                  child: const Text(
                    "Game History",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final refRead =
                    ref.read(jackpotHistorySwitchNotifierProvider.notifier);
                final refWatch =
                    ref.watch(jackpotHistorySwitchNotifierProvider);
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: refWatch == "My History"
                        ? darkBlue
                        : const Color(0xffEAEAEA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    refRead.updateSelection("My History");
                  },
                  child: const Text(
                    "My History",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        const JackpotHistorChanger(),
      ],
    );
  }
}

class JackpotHistorChanger extends StatelessWidget {
  const JackpotHistorChanger({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final refWatch = ref.watch(jackpotHistorySwitchNotifierProvider);
        return refWatch == "Game History"
            ? const JackpotGameHistory()
            : const MyJackpotHistory();
      },
    );
  }
}

class JackpotGameHistory extends StatelessWidget {
  const JackpotGameHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("No Game History");
  }
}

class MyJackpotHistory extends StatelessWidget {
  const MyJackpotHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("No My History");
  }
}
