class GetParticularPlayerModel {
  String? status;
  Data? data;

  GetParticularPlayerModel({this.status, this.data});

  GetParticularPlayerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? userName;
  String? mpin;
  String? password;
  String? mobile;
  int? wallet;
  bool? verified;
  bool? status;
  String? branchName;
  String? bankName;
  String? accountHolderName;
  String? accountNo;
  String? ifscCode;
  String? referralCode;
  String? upiId;
  String? upiNumber;
  bool? betting;
  bool? transfer;
  String? fcm;
  bool? personalNotification;
  bool? mainNotification;
  bool? starlineNotification;
  bool? galidisawarNotification;
  String? createdAt;
  String? updatedAt;
  String? address;
  String? addressLane1;
  String? addressLane2;
  String? area;
  String? districtId;
  String? houseNo;
  String? pinCode;
  String? stateId;
  bool? otpVerified;
  bool? authentication;

  Data(
      {this.sId,
      this.userName,
      this.mpin,
      this.password,
      this.mobile,
      this.wallet,
      this.verified,
      this.status,
      this.branchName,
      this.bankName,
      this.accountHolderName,
      this.accountNo,
      this.ifscCode,
      this.referralCode,
      this.upiId,
      this.upiNumber,
      this.betting,
      this.transfer,
      this.fcm,
      this.personalNotification,
      this.mainNotification,
      this.starlineNotification,
      this.galidisawarNotification,
      this.createdAt,
      this.updatedAt,
      this.address,
      this.addressLane1,
      this.addressLane2,
      this.area,
      this.districtId,
      this.houseNo,
      this.pinCode,
      this.stateId,
      this.otpVerified,
      this.authentication});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['user_name'];
    mpin = json['mpin'];
    password = json['password'];
    mobile = json['mobile'];
    wallet = json['wallet'] is num ? json['wallet'].toInt() : json['wallet'];
    verified = json['verified'];
    status = json['status'];
    branchName = json['branch_name'];
    bankName = json['bank_name'];
    accountHolderName = json['account_holder_name'];
    accountNo = json['account_no'];
    ifscCode = json['ifsc_code'];
    referralCode = json['referral_code'];
    upiId = json['upi_id'];
    upiNumber = json['upi_number'];
    betting = json['betting'];
    transfer = json['transfer'];
    fcm = json['fcm'];
    personalNotification = json['personal_notification'];
    mainNotification = json['main_notification'];
    starlineNotification = json['starline_notification'];
    galidisawarNotification = json['galidisawar_notification'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    address = json['address'];
    addressLane1 = json['address_lane_1'];
    addressLane2 = json['address_lane_2'];
    area = json['area'];
    districtId = json['district_id'];
    houseNo = json['house_no'];
    pinCode = json['pin_code'];
    stateId = json['state_id'];
    otpVerified = json['otp_verified'];
    authentication = json['authentication'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['user_name'] = userName;
    data['mpin'] = mpin;
    data['password'] = password;
    data['mobile'] = mobile;
    data['wallet'] = wallet;
    data['verified'] = verified;
    data['status'] = status;
    data['branch_name'] = branchName;
    data['bank_name'] = bankName;
    data['account_holder_name'] = accountHolderName;
    data['account_no'] = accountNo;
    data['ifsc_code'] = ifscCode;
    data['referral_code'] = referralCode;
    data['upi_id'] = upiId;
    data['upi_number'] = upiNumber;
    data['betting'] = betting;
    data['transfer'] = transfer;
    data['fcm'] = fcm;
    data['personal_notification'] = personalNotification;
    data['main_notification'] = mainNotification;
    data['starline_notification'] = starlineNotification;
    data['galidisawar_notification'] = galidisawarNotification;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['address'] = address;
    data['address_lane_1'] = addressLane1;
    data['address_lane_2'] = addressLane2;
    data['area'] = area;
    data['district_id'] = districtId;
    data['house_no'] = houseNo;
    data['pin_code'] = pinCode;
    data['state_id'] = stateId;
    data['otp_verified'] = otpVerified;
    data['authentication'] = authentication;
    return data;
  }
}
