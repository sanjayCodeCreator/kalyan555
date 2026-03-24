import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sm_project/utils/filecollection.dart';

void toast(String message, {BuildContext? context}) {
  if (context != null) {
    if (context.mounted) {
      CherryToast.info(
        toastPosition: Position.bottom,
        title: Text(
          message,
          style: const TextStyle(color: Colors.black),
        ),
      ).show(context);
    }
  } else {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: whiteBackgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}
