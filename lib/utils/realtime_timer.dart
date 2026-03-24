import 'dart:async';

import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/filecollection.dart';

class TimerComponent extends StatefulWidget {
  final Color? color;
  const TimerComponent({this.color, super.key});

  @override
  State<TimerComponent> createState() => _TimerComponentState();
}

class _TimerComponentState extends State<TimerComponent> {
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
    if (timer == null) {
      if (!(timer?.isActive ?? false)) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final refParticularWatch = ref.watch(getParticularPlayerNotifierProvider);
      return SizedBox(
        width: 150,
        height: 40,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  refParticularWatch
                              .value?.getParticularPlayerModel?.data?.mpin !=
                          null
                      ? Text(
                          convert24HrTo12Hr(
                              '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
                              seconds: start),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.color ?? textColor))
                      : const Text(''),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
