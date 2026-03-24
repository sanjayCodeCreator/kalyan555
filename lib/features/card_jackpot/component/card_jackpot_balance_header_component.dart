import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/card_jackpot/progress_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class CardJackpotBalanceHeader extends HookConsumerWidget {
  const CardJackpotBalanceHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel(context: context);
      return;
    }, []);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        walletJackpotIcon,
                        width: 30,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total"),
                          Text(
                            "Wallet balance",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Consumer(builder: (context, ref, child) {
                        final refWatch = ref
                            .watch(getParticularPlayerNotifierProvider)
                            .value;
                        final int balance =
                            refWatch?.getParticularPlayerModel?.data?.wallet ??
                                0;
                        return Text(
                          "₹ $balance",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        );
                      }),
                      const SizedBox(
                        width: 10,
                      ),
                      Consumer(builder: (context, ref, _) {
                        final refRead =
                            ref.read(retryProgressNotifierProvider.notifier);
                        final refWatch =
                            ref.watch(retryProgressNotifierProvider);
                        return InkWell(
                          onTap: () {
                            ref
                                .read(getParticularPlayerNotifierProvider
                                    .notifier)
                                .getParticularPlayerModel(context: context);
                            refRead.runSpin();
                          },
                          child: Transform.rotate(
                            angle: refWatch,
                            child: const Icon(
                              Icons.sync,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      })
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.push(RouteNames.deposit);
                      },
                      child: const Text("Deposit"),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlue,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.push(RouteNames.withdrawal);
                      },
                      child: const Text("Withdrawal"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
