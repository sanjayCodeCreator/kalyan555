class LogicLoomPaymentModel {
  String? status;
  String? message;
  LogicLoomPaymentData? data;

  LogicLoomPaymentModel({this.status, this.message, this.data});

  LogicLoomPaymentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? LogicLoomPaymentData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LogicLoomPaymentData {
  String? upiIntentUrl;
  String? custRefNum;

  LogicLoomPaymentData({this.upiIntentUrl, this.custRefNum});

  LogicLoomPaymentData.fromJson(Map<String, dynamic> json) {
    upiIntentUrl = json['upiIntentUrl'];
    custRefNum = json['custRefNum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['upiIntentUrl'] = upiIntentUrl;
    data['custRefNum'] = custRefNum;
    return data;
  }
}