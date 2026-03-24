import 'package:sm_project/features/card_jackpot/card_jackpot_router.dart';
import 'package:sm_project/features/card_jackpot/component/jackpot_rates_component.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class JackpotRateTimeComponent extends StatefulWidget {
  const JackpotRateTimeComponent({super.key});

  @override
  State<JackpotRateTimeComponent> createState() =>
      _JackpotRateTimeComponentState();
}

class _JackpotRateTimeComponentState extends State<JackpotRateTimeComponent> {
  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromMinute(3),
  );
  bool isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    stopWatchTimer.onStartTimer();
    stopWatchTimer.secondTime.listen((value) {
      if (value < 6) {
        if (!isDialogVisible) {
          showDialog(
            context: context,
            useSafeArea: true,
            builder: (context) {
              return PopScope(
                canPop: false,
                child: AlertDialog(
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.black.withOpacity(0.4),
                  surfaceTintColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(),
                  title: StreamBuilder<int>(
                      stream: stopWatchTimer.secondTime,
                      builder: (context, snapshot) {
                        if (snapshot.data == 0) {
                          Future.delayed(
                            const Duration(seconds: 1),
                            () {
                              showDialog(
                                context: this.context,
                                builder: (context) {
                                  final size = MediaQuery.of(context).size;
                                  return PopScope(
                                    canPop: false,
                                    child: AlertDialog(
                                      insetPadding: const EdgeInsets.all(16),
                                      backgroundColor: Colors.white,
                                      surfaceTintColor: Colors.white,
                                      titlePadding: EdgeInsets.zero,
                                      title: SizedBox(
                                        width: size.width * 0.8,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "RESULT",
                                            style: TextStyle(
                                              fontSize: 23,
                                              color: darkBlue,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationStyle:
                                                  TextDecorationStyle.solid,
                                              decorationColor: darkBlue,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          SizedBox(
                                            width: size.width * 0.7,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                context.pop();
                                                this.context.pushReplacement(
                                                    CardJackpotPath
                                                        .cardJackpot);
                                              },
                                              child: const Text("Okay"),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                          context.pop();
                        }
                        final size = MediaQuery.of(context).size;
                        return SizedBox(
                          width: size.width,
                          height: size.height -
                              (MediaQuery.of(context).padding.top +
                                  MediaQuery.of(context).padding.bottom +
                                  MediaQuery.of(context).viewInsets.top +
                                  MediaQuery.of(context).viewInsets.bottom +
                                  MediaQuery.of(context).viewPadding.top +
                                  MediaQuery.of(context).viewPadding.bottom +
                                  100),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  "0 ${snapshot.data}",
                                  style: const TextStyle(
                                    fontSize: 60,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              );
            },
          );
        }
        isDialogVisible = true;
      }
    });
  }

  @override
  void dispose() {
    stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: darkBlue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  showJackpotRates(context: context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xffffda8c),
                          )),
                      child: const Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          right: 16,
                          top: 4,
                          bottom: 4,
                        ),
                        child: Text(
                          "Rates",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "0254550",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Time Remaining"),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffcc9113),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: StreamBuilder<int>(
                              stream: stopWatchTimer.minuteTime,
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data.toString().length == 1
                                      ? "0"
                                      : snapshot.data.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                );
                              }),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Container(
                        width: 26,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffcc9113),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: StreamBuilder<int>(
                              stream: stopWatchTimer.minuteTime,
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data.toString().length == 1
                                      ? snapshot.data.toString()
                                      : snapshot.data
                                          .toString()
                                          .split("")[1]
                                          .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                );
                              }),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Container(
                        width: 26,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffcc9113),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            ":",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Container(
                        width: 26,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffcc9113),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: StreamBuilder<int>(
                              stream: stopWatchTimer.secondTime,
                              builder: (context, snapshot) {
                                return Text(
                                  ((snapshot.data?.toInt() ?? 0) -
                                                  (stopWatchTimer
                                                          .minuteTime.value *
                                                      60))
                                              .toString()
                                              .length ==
                                          1
                                      ? "0"
                                      : ((snapshot.data?.toInt() ?? 0) -
                                              (stopWatchTimer.minuteTime.value *
                                                  60))
                                          .toString()[0],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                );
                              }),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Container(
                        width: 26,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xffcc9113),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: StreamBuilder<int>(
                              stream: stopWatchTimer.secondTime,
                              builder: (context, snapshot) {
                                return Text(
                                  ((snapshot.data?.toInt() ?? 0) -
                                                  (stopWatchTimer
                                                          .minuteTime.value *
                                                      60))
                                              .toString()
                                              .length ==
                                          1
                                      ? ((snapshot.data?.toInt() ?? 0) -
                                              (stopWatchTimer.minuteTime.value *
                                                  60))
                                          .toString()[0]
                                      : ((snapshot.data?.toInt() ?? 0) -
                                              (stopWatchTimer.minuteTime.value *
                                                  60))
                                          .toString()[1],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
