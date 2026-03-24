import 'dart:async';

import 'package:one_clock/one_clock.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/filecollection.dart';

class TimeComponent extends StatefulWidget {
  const TimeComponent({super.key});

  @override
  State<TimeComponent> createState() => _TimeComponentState();
}

class _TimeComponentState extends State<TimeComponent> {
  Timer? timer;
  int start = DateTime.now().second;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (mounted) {
          setState(() {
            start = DateTime.now().second;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final refParticularWatch = ref.watch(getParticularPlayerNotifierProvider);
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                refParticularWatch
                            .value?.getParticularPlayerModel?.data?.mpin  !=
                        null
                    ? AnalogClock(
                        decoration: BoxDecoration(
                            border: Border.all(width: 2.0, color: Colors.black),
                            color: Colors.black,
                            shape: BoxShape.circle),
                        width: 65.0,
                        height: 50,
                        isLive: true,
                        hourHandColor: Colors.white,
                        minuteHandColor: Colors.white,
                        showSecondHand: true,
                        numberColor: Colors.white,
                        showNumbers: true,
                        showAllNumbers: true,
                        textScaleFactor: 1.6,
                        showTicks: true,
                        showDigitalClock: false,
                        datetime: DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          TimeOfDay.now().hour,
                          TimeOfDay.now().minute,
                          DateTime.now().second,
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(width: 5),
                refParticularWatch
                            .value?.getParticularPlayerModel?.data?.mpin  !=
                        null
                    ? Text(
                        convert24HrTo12Hr(
                            '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
                            seconds: start),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textColor))
                    : const Text('Getting time'),
              ],
            ),
          ),
        ],
      );
    });
  }
}
