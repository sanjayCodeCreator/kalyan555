class ContactUsModel {
  String? status;
  String? appLink;
  String? whatsapp;
  String? mobile;
  String? telegram;
  String? email1;
  String? email2;

  ContactUsModel(
      {this.status,
      this.appLink,
      this.whatsapp,
      this.mobile,
      this.telegram,
      this.email1,
      this.email2});

  ContactUsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    appLink = json['app_link'];
    whatsapp = json['whatsapp'];
    mobile = json['mobile'];
    telegram = json['telegram'];
    email1 = json['email_1'];
    email2 = json['email_2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['app_link'] = appLink;
    data['whatsapp'] = whatsapp;
    data['mobile'] = mobile;
    data['telegram'] = telegram;
    data['email_1'] = email1;
    data['email_2'] = email2;
    return data;
  }
}
