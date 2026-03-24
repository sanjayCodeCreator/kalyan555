import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/utils/filecollection.dart';

bool isStopGaliDesawarGameExecution({required GaliDeswarGameData? gameData}) {
  if (gameData?.status == false) {
    return true;
  }
  if (gameData?.marketStatus == false) {
    return true;
  }
  return false;
}

bool isTimePassed(String timeString) {
  List<String> timeComponents = timeString.split(":");
  int hour = int.parse(timeComponents[0]);
  int minute = int.parse(timeComponents[1]);

  TimeOfDay closeTime = TimeOfDay(hour: hour, minute: minute);

  TimeOfDay currentTime = TimeOfDay.now();
  // Compare the target time with the current time
  if (currentTime.hour > closeTime.hour ||
      (currentTime.hour == closeTime.hour &&
          currentTime.minute >= closeTime.minute)) {
    //Time has passed
    return true;
  } else {
    // Time has not passed
    return false;
  }
}
