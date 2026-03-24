class SendSMSModel {
  String? status;
  String? message;
  User? user;
  String? accessToken;

  SendSMSModel({this.status, this.user, this.accessToken, this.message});

  SendSMSModel.fromJson(Map<String, dynamic> json) {
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
  String? userName;
  String? mpin;
  String? mobile;
  int? wallet;
  bool? verified;
  bool? reset;
  bool? status;
  String? houseNo;
  String? addressLane1;
  String? addressLane2;
  String? area;
  String? pinCode;
  String? stateId;
  String? districtId;
  String? branchName;
  String? bankName;
  String? address;
  String? accountHolderName;
  String? accountNo;
  String? ifscCode;
  String? paytmNo;
  String? googlePayNo;
  String? phonePayNo;
  bool? betting;
  bool? transfer;
  String? fcm;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? accessToken;
  String? refreshToken;

  User(
      {this.sId,
      this.userName,
      this.mpin,
      this.mobile,
      this.wallet,
      this.verified,
      this.reset,
      this.status,
      this.houseNo,
      this.addressLane1,
      this.addressLane2,
      this.area,
      this.pinCode,
      this.stateId,
      this.districtId,
      this.branchName,
      this.bankName,
      this.address,
      this.accountHolderName,
      this.accountNo,
      this.ifscCode,
      this.paytmNo,
      this.googlePayNo,
      this.phonePayNo,
      this.betting,
      this.transfer,
      this.fcm,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.accessToken,
      this.refreshToken});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['user_name'];
    mpin = json['mpin'];
    mobile = json['mobile'];
    wallet = json['wallet'];
    verified = json['verified'];
    reset = json['reset'];
    status = json['status'];
    houseNo = json['house_no'];
    addressLane1 = json['address_lane_1'];
    addressLane2 = json['address_lane_2'];
    area = json['area'];
    pinCode = json['pin_code'];
    stateId = json['state_id'];
    districtId = json['district_id'];
    branchName = json['branch_name'];
    bankName = json['bank_name'];
    address = json['address'];
    accountHolderName = json['account_holder_name'];
    accountNo = json['account_no'];
    ifscCode = json['ifsc_code'];
    paytmNo = json['paytm_no'];
    googlePayNo = json['google_pay_no'];
    phonePayNo = json['phone_pay_no'];
    betting = json['betting'];
    transfer = json['transfer'];
    fcm = json['fcm'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user_name'] = userName;
    data['mpin'] = mpin;
    data['mobile'] = mobile;
    data['wallet'] = wallet;
    data['verified'] = verified;
    data['reset'] = reset;
    data['status'] = status;
    data['house_no'] = houseNo;
    data['address_lane_1'] = addressLane1;
    data['address_lane_2'] = addressLane2;
    data['area'] = area;
    data['pin_code'] = pinCode;
    data['state_id'] = stateId;
    data['district_id'] = districtId;
    data['branch_name'] = branchName;
    data['bank_name'] = bankName;
    data['address'] = address;
    data['account_holder_name'] = accountHolderName;
    data['account_no'] = accountNo;
    data['ifsc_code'] = ifscCode;
    data['paytm_no'] = paytmNo;
    data['google_pay_no'] = googlePayNo;
    data['phone_pay_no'] = phonePayNo;
    data['betting'] = betting;
    data['transfer'] = transfer;
    data['fcm'] = fcm;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    return data;
  }
}
