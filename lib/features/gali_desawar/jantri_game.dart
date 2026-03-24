import 'package:sm_project/features/gali_desawar/cross_game_notifier.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_game_mode_notifier.dart';
import 'package:sm_project/features/gali_desawar/jantri_notifier.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/features/gali_desawar/open_play_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:sm_project/utils/realtime_timer.dart';

class JantriGame extends StatelessWidget {
  final GaliDeswarGameData? gameData;
  final String tag;
  const JantriGame({super.key, required this.tag, this.gameData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text(
          'Jantri Game',
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
                      if (gameMode == GaliDesawarGameMode.jantri) {
                        ref.read(jantriNotifierProvider.notifier).submitData(
                            context: context, gameData: gameData, tag: tag);
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
          if (gameMode != GaliDesawarGameMode.jantri) {
            return const SizedBox();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SelectGameComponent(),
                const SizedBox(height: 10),
                const Text(
                  "Enter Amount Below",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.5),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: 100,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 0,
                    mainAxisExtent: 76,
                  ),
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 70,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xff56a6a6),
                              border: Border.all(width: 1, color: Colors.black),
                            ),
                            child: Center(
                              child: Text(
                                index == 99
                                    ? "00"
                                    : index < 9
                                        ? "0${index + 1}"
                                        : "${index + 1}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 0,
                          ),
                          Container(
                            width: 70,
                            height: 35,
                            decoration: const BoxDecoration(
                                border: Border(
                              left: BorderSide(width: 1, color: Colors.black),
                              bottom: BorderSide(width: 1, color: Colors.black),
                              right: BorderSide(width: 1, color: Colors.black),
                            )),
                            child: Consumer(builder: (context, ref, _) {
                              final refRead =
                                  ref.read(jantriNotifierProvider.notifier);
                              return TextFormField(
                                onChanged: (value) {
                                  refRead.updateData(
                                      betNumber: index == 99
                                          ? "00"
                                          : index < 9
                                              ? "0${index + 1}"
                                              : "${index + 1}",
                                      betAmount: value,
                                      isHarupAndar: false,
                                      isHarupNo: false);
                                },
                                keyboardType: TextInputType.number,
                                cursorHeight: 20,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(3),
                                  fillColor: Color(0xffebf7f7),
                                  filled: true,
                                  border: InputBorder.none,
                                ),
                              );
                            }),
                          )
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Andar/A",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4),
                ),
                const SizedBox(
                  height: 8,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 0,
                    mainAxisExtent: 76,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xff56a6a6),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child: Center(
                            child: Text(
                              index == 9 ? "0" : "${index + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        Container(
                          width: 70,
                          height: 35,
                          decoration: const BoxDecoration(
                              border: Border(
                            left: BorderSide(width: 1, color: Colors.black),
                            bottom: BorderSide(width: 1, color: Colors.black),
                            right: BorderSide(width: 1, color: Colors.black),
                          )),
                          child: Consumer(builder: (context, ref, _) {
                            final refRead =
                                ref.read(jantriNotifierProvider.notifier);
                            return TextFormField(
                              onChanged: (value) {
                                refRead.updateData(
                                    betNumber:
                                        index == 9 ? "0" : "${index + 1}",
                                    betAmount: value,
                                    isHarupAndar: true,
                                    isHarupNo: true);
                              },
                              keyboardType: TextInputType.number,
                              cursorHeight: 20,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(3),
                                fillColor: Color(0xffebf7f7),
                                filled: true,
                                border: InputBorder.none,
                              ),
                            );
                          }),
                        )
                      ],
                    );
                  },
                ),
                const Text(
                  "Bahar/B",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4),
                ),
                const SizedBox(
                  height: 8,
                ),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 0,
                    mainAxisExtent: 76,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 70,
                          height: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xff56a6a6),
                            border: Border.all(width: 1, color: Colors.black),
                          ),
                          child: Center(
                            child: Text(
                              index == 9 ? "0" : "${index + 1}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        Container(
                          width: 70,
                          height: 35,
                          decoration: const BoxDecoration(
                              border: Border(
                            left: BorderSide(width: 1, color: Colors.black),
                            bottom: BorderSide(width: 1, color: Colors.black),
                            right: BorderSide(width: 1, color: Colors.black),
                          )),
                          child: Consumer(builder: (context, ref, _) {
                            final refRead =
                                ref.read(jantriNotifierProvider.notifier);
                            return TextFormField(
                              onChanged: (value) {
                                refRead.updateData(
                                    betNumber:
                                        index == 9 ? "0" : "${index + 1}",
                                    betAmount: value,
                                    isHarupAndar: false,
                                    isHarupNo: true);
                              },
                              keyboardType: TextInputType.number,
                              cursorHeight: 20,
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(3),
                                fillColor: Color(0xffebf7f7),
                                filled: true,
                                border: InputBorder.none,
                              ),
                            );
                          }),
                        )
                      ],
                    );
                  },
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
        }),
      ),
    );
  }
}
