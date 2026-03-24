class LoginModel {
  String? status;
  String? message;
  TokenData? tokenData;
  String? cookie;
  Data? data;

  LoginModel(
      {this.status, this.message, this.tokenData, this.cookie, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    tokenData = json['tokenData'] != null
        ? TokenData.fromJson(json['tokenData'])
        : null;
    cookie = json['cookie'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (tokenData != null) {
      data['tokenData'] = tokenData!.toJson();
    }
    data['cookie'] = cookie;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TokenData {
  String? expiresIn;
  String? token;

  TokenData({this.expiresIn, this.token});

  TokenData.fromJson(Map<String, dynamic> json) {
    expiresIn = json['expiresIn'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['expiresIn'] = expiresIn;
    data['token'] = token;
    return data;
  }
}

class Data {
  String? id;
  String? mobile;
  bool? verified;

  Data({this.id, this.mobile, this.verified});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    mobile = json['mobile'];
    verified = json['verified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['mobile'] = mobile;
    data['verified'] = verified;
    return data;
  }
}
