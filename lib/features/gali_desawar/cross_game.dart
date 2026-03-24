import 'package:sm_project/features/gali_desawar/cross_game_notifier.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_game_mode_notifier.dart';
import 'package:sm_project/features/gali_desawar/jantri_notifier.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/features/gali_desawar/open_play_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:sm_project/utils/realtime_timer.dart';

class CrossGameComponent extends StatelessWidget {
  final GaliDeswarGameData? gameData;
  final String tag;
  const CrossGameComponent({super.key, required this.tag, this.gameData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'Cross Game',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: buttonForegroundColor,
          ),
        ),
        actions: const [
          TimerComponent(
            color: Colors.white,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Container(
          height: 50,
          decoration:
              const BoxDecoration(color: whiteBackgroundColor, boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ]),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: whiteBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Consumer(builder: (context, ref, _) {
                        int totalAmount = 0;
                        final gameMode = ref
                            .watch(galiDesawarGameModelNotifierProvider)
                            .value;
                        if (gameMode == GaliDesawarGameMode.openPlay) {
                          final refWatch =
                              ref.watch(openPlayNotifierProvider).value;
                          totalAmount = refWatch?.totalAmount ?? 0;
                        }
                        if (gameMode == GaliDesawarGameMode.jantri) {
                          final refWatch =
                              ref.watch(jantriNotifierProvider).value;
                          totalAmount = refWatch?.totalAmount ?? 0;
                        }
                        if (gameMode == GaliDesawarGameMode.cross) {
                          final refWatch =
                              ref.watch(crossGameNotifierProvider).value;
                          totalAmount = refWatch?.totalAmount ?? 0;
                        }
                        return Text('Rs. $totalAmount',
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold));
                      }),
                      Text('Total Amount', style: TextStyle(color: darkBlue)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Consumer(builder: (context, ref, _) {
                  final gameMode =
                      ref.watch(galiDesawarGameModelNotifierProvider).value;
                  return InkWell(
                    onTap: () {
                      // if (gameMode == GaliDesawarGameMode.openPlay) {
                      //   ref.read(openPlayNotifierProvider.notifier).submitData(
                      //         context,
                      //       );
                      // }
                      // if (gameMode == GaliDesawarGameMode.jantri) {
                      //   ref
                      //       .read(jantriNotifierProvider.notifier)
                      //       .submitData(context: context);
                      // }
                      if (gameMode == GaliDesawarGameMode.cross) {
                        ref.read(crossGameNotifierProvider.notifier).submitData(
                            context: context,
                            gameData: gameData,
                            tag: 'galidisawar');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: darkBlue,
                          gradient: const LinearGradient(colors: [
                            Color(0xff52b09c),
                            Color(0xff689cc6),
                          ]),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 1.0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ]),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('PLACE BET',
                              style: TextStyle(
                                  color: whiteBackgroundColor, fontSize: 18)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer(builder: (context, ref, _) {
          final gameMode =
              ref.watch(galiDesawarGameModelNotifierProvider).value;
          if (gameMode != GaliDesawarGameMode.cross) {
            return const SizedBox();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const SelectGameComponent(),
                Row(children: [
                  Expanded(child: Consumer(builder: (context, ref, _) {
                    final refWatch = ref.watch(crossGameNotifierProvider).value;
                    return Consumer(builder: (context, ref, _) {
                      final refRead =
                          ref.read(crossGameNotifierProvider.notifier);
                      return CustomTextFormField(
                        controller: refWatch?.number,
                        hintText: 'ENTER NUMBERS',
                        onChanged: (value) {
                          refRead.calculateTotalAmount();
                        },
                        keyboardType: TextInputType.number,
                        suffixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 6, 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 1,
                                height: 40,
                                color: darkBlue,
                              ),
                              const SizedBox(width: 5),
                              Consumer(builder: (context, ref, _) {
                                final refRead = ref
                                    .read(crossGameNotifierProvider.notifier);
                                return InkWell(
                                  onTap: () {
                                    refRead.toggleNumberWithoutJoda();
                                  },
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Without\nJoda',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              height: 1),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: Consumer(
                                              builder: (context, ref, _) {
                                            final refRead = ref.read(
                                                crossGameNotifierProvider
                                                    .notifier);
                                            final refWatch = ref
                                                .watch(
                                                    crossGameNotifierProvider)
                                                .value;
                                            return Checkbox(
                                              visualDensity:
                                                  VisualDensity.comfortable,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              value:
                                                  refWatch?.isNumberWithoutJoda,
                                              onChanged: (value) {
                                                refRead
                                                    .toggleNumberWithoutJoda();
                                              },
                                            );
                                          }),
                                        ),
                                      ]),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    });
                  })),
                  const SizedBox(width: 10),
                  const Text('=',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(child: Consumer(builder: (context, ref, _) {
                    final refRead =
                        ref.read(crossGameNotifierProvider.notifier);
                    final refWatch = ref.watch(crossGameNotifierProvider).value;
                    return CustomTextFormField(
                      controller: refWatch?.numberAmount,
                      hintText: 'ENTER AMOUNT',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        refRead.calculateTotalAmount();
                      },
                    );
                  })),
                ]),
                const SizedBox(width: 10),
                Consumer(builder: (context, ref, _) {
                  final refWatch = ref.watch(crossGameNotifierProvider).value;
                  if (refWatch?.showCard == false) {
                    return const SizedBox();
                  }
                  final selectedList = refWatch?.selectedNumber;
                  if (selectedList?.isEmpty == true) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            itemCount: selectedList?.length ?? 0,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final data = selectedList?[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0, bottom: 8, top: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(data?.betNumber ?? ""),
                                    const Text("="),
                                    Text(data?.betAmount.toString() ?? ""),
                                    InkWell(
                                      onTap: () {
                                        ref
                                            .read(crossGameNotifierProvider
                                                .notifier)
                                            .removeSelectedNumber(index);
                                      },
                                      child: Container(
                                        width: 25,
                                        height: 25,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}
