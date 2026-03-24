import 'dart:convert';
import 'dart:developer';

import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/controller/model/login_model.dart';

class UserData {
  static LoginModel? geUserData() {
    try {
      final String? data = Prefs.getString(PrefNames.userData);
      if (data != null) {
        log(data);
        final json = jsonDecode(data);
        return LoginModel.fromJson(json);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }
}
