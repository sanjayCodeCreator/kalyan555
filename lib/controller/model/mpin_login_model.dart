class MPINLogin {
  String? status;
  String? message;
  User? user;
  String? accessToken;

  MPINLogin({this.status, this.message, this.user, this.accessToken});

  MPINLogin.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['access_token'] = accessToken;
    return data;
  }
}

class User {
  String? sId;
  String? mpin;
  bool? verified;
  String? accessToken;
  String? refreshToken;
  String? updatedAt;

  User(
      {this.sId,
      this.mpin,
      this.verified,
      this.accessToken,
      this.refreshToken,
      this.updatedAt});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mpin = json['mpin'];
    verified = json['verified'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['mpin'] = mpin;
    data['verified'] = verified;
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
