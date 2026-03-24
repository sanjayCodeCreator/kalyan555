import 'dart:convert';
import 'dart:developer';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/utils/filecollection.dart';

class UserParticularPlayer {
  static Data? getParticularUserData() {
    try {
      final String? data = Prefs.getString(PrefNames.userParticularPlayer);
      if (data != null) {
        final json = jsonDecode(data);
        return Data.fromJson(json);
      }
    } catch (e) {
      log("$e");
    }
    return null;
  }
}
