class TransactionHistoryModel {
  String? status;
  int? total;
  List<Data>? data;

  TransactionHistoryModel({this.status, this.total, this.data});

  TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    total = json['total'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  UserId? userId;
  int? amount;
  String? type;
  String? status;
  String? taxId;
  String? refId;
  int? prevBalance;
  int? currentBalance;
  String? createdAt;
  String? updatedAt;
  int? iV;
  Null agentId;
  String? note;
  String? transferType;

  Data(
      {this.sId,
      this.userId,
      this.amount,
      this.type,
      this.status,
      this.taxId,
      this.refId,
      this.prevBalance,
      this.currentBalance,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.agentId,
      this.note,
      this.transferType});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['user_id'] != null ? UserId.fromJson(json['user_id']) : null;
    amount = json['amount'];
    type = json['type'];
    status = json['status'];
    taxId = json['tax_id'];
    refId = json['ref_id'];
    prevBalance = json['prev_balance'];
    currentBalance = json['current_balance'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    agentId = json['agent_id'];
    note = json['note'];
    transferType = json['transfer_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) {
      data['user_id'] = userId!.toJson();
    }
    data['amount'] = amount;
    data['type'] = type;
    data['status'] = status;
    data['tax_id'] = taxId;
    data['ref_id'] = refId;
    data['prev_balance'] = prevBalance;
    data['current_balance'] = currentBalance;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['agent_id'] = agentId;
    data['note'] = note;
    data['transfer_type'] = transferType;
    return data;
  }
}

class UserId {
  String? sId;
  String? userName;
  String? mpin;
  String? password;
  String? mobile;
  int? wallet;
  bool? verified;
  bool? otpVerified;
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
  int? iV;
  bool? authentication;
  String? lastLogin;
  bool? transactionPermanentlyBlocked;
  Null transactionBlockedUntil;
  bool? isShow;

  UserId(
      {this.sId,
      this.userName,
      this.mpin,
      this.password,
      this.mobile,
      this.wallet,
      this.verified,
      this.otpVerified,
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
      this.iV,
      this.authentication,
      this.lastLogin,
      this.transactionPermanentlyBlocked,
      this.transactionBlockedUntil,
      this.isShow});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userName = json['user_name'];
    mpin = json['mpin'];
    password = json['password'];
    mobile = json['mobile'];
    wallet = json['wallet'];
    verified = json['verified'];
    otpVerified = json['otp_verified'];
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
    iV = json['__v'];
    authentication = json['authentication'];
    lastLogin = json['last_login'];
    transactionPermanentlyBlocked = json['transaction_permanently_blocked'];
    transactionBlockedUntil = json['transaction_blocked_until'];
    isShow = json['is_show'];
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
    data['otp_verified'] = otpVerified;
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
    data['__v'] = iV;
    data['authentication'] = authentication;
    data['last_login'] = lastLogin;
    data['transaction_permanently_blocked'] = transactionPermanentlyBlocked;
    data['transaction_blocked_until'] = transactionBlockedUntil;
    data['is_show'] = isShow;
    return data;
  }
}
