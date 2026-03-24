import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sm_project/features/gali_desawar/cross_game.dart';
import 'package:sm_project/features/gali_desawar/cross_game_notifier.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_game_mode_notifier.dart';
import 'package:sm_project/features/gali_desawar/jantri_game.dart';
import 'package:sm_project/features/gali_desawar/jantri_notifier.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/features/gali_desawar/open_play_game.dart';
import 'package:sm_project/features/gali_desawar/open_play_notifier.dart';
import 'package:sm_project/utils/colors.dart';

class GameButtonComponent extends StatelessWidget {
  final GaliDeswarGameData? gameData;
  final String tag;
  const GameButtonComponent({super.key, required this.tag, this.gameData});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final refRead = ref.read(galiDesawarGameModelNotifierProvider.notifier);
      return Column(children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  refRead.updateGameMode(GaliDesawarGameMode.openPlay);
                  ref.read(openPlayNotifierProvider.notifier).clearAll();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return OpenPlayGameComponent(
                      gameData: gameData,
                      tag: tag,
                    );
                  }));
                },
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset('assets/images/openplay.png',
                            width: 160),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('OPEN',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                        ),
                                      ])),
                              const SizedBox(height: 6),
                              Text('PLAY',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                        ),
                                      ])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: InkWell(
                onTap: () {
                  refRead.updateGameMode(GaliDesawarGameMode.jantri);
                  ref.read(jantriNotifierProvider.notifier).clearAll();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return JantriGame(
                      gameData: gameData,
                      tag: tag,
                    );
                  }));
                },
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child:
                            Image.asset('assets/images/jantri.png', width: 160),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('JANTRI',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                        ),
                                      ])),
                              const SizedBox(height: 6),
                              Text('GAME',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                        ),
                                      ])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            refRead.updateGameMode(GaliDesawarGameMode.cross);
            ref.read(crossGameNotifierProvider.notifier).clearAll();
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CrossGameComponent(
                gameData: gameData,
                tag: tag,
              );
            }));
          },
          child: Stack(
            children: [
              Opacity(
                opacity: 0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset('assets/images/openplay.png', width: 180),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('CROSS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(1, 1),
                                  ),
                                ])),
                        const SizedBox(height: 6),
                        Text('GAME',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(1, 1),
                                  ),
                                ])),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]);
    });
  }
}
