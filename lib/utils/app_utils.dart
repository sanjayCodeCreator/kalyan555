import 'package:permission_handler/permission_handler.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUtils {
  static launchURL(String url) async => await canLaunchUrl(Uri.parse(url))
      ? await launchUrl(Uri.parse(url))
      : throw 'Could not launch $url';

  static Future<void> handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
    debugPrint(status.toString());
  }
}


String convert24HrTo12Hr(String time24, {int? seconds}) {
  if(time24.isEmpty) {
    return '';
  }
  if(time24 == "-") {
    return "-";
  }
  List<String> parts = time24.split(":");
  int hour = int.parse(parts[0]);
  int minute = int.parse(parts[1]);
  String period = 'AM';

  if (hour >= 12) {
    period = 'PM';
    hour = hour == 12 ? 12 : hour - 12;
  } else {
    period = 'AM';
    hour = hour == 0 ? 12 : hour;
  }
  String hourStr = hour.toString().padLeft(2, '0');
  String minuteStr = minute.toString().padLeft(2, '0');

  return seconds != null
      ? '$hourStr:$minuteStr:${seconds < 10 ? "0$seconds" : seconds} $period'
      : '$hourStr:$minuteStr $period';
}