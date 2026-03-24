class GetSettingModel {
  String? status;
  Data? data;

  GetSettingModel({this.status, this.data});

  GetSettingModel.fromJson(Map<String, dynamic> json) {
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
  Deposit? deposit;
  Deposit? withdraw;
  Deposit? transfer;
  Deposit? betting;
  WithdrawlOffDay? withdrawlOffDay;
  Rates? rates;
  AviatorSettings? aviator;
  String? howToPlay;
  String? rules;
  String? rouletteRules;
  String? sId;
  String? name;
  int? referralBonus;
  int? joiningBonus;
  String? merchantUpi;
  String? withdrawOpen;
  String? withdrawClose;
  String? appLink;
  String? webAppLink;
  String? webLink;
  String? shareMessage;
  bool? maintainence;
  String? maintainenceMsg;
  String? appVersion;
  bool? appVersionReq;
  bool? webtoggle;
  String? mobile;
  String? telegram;
  bool? autoVerified;
  bool? autoNotification;
  String? merchantQr;
  String? whatsapp;
  String? whatsappText;
  String? email1;
  String? email2;
  String? facebook;
  String? twitter;
  String? youtube;
  String? instagram;
  String? privacyPolicy;
  String? welcomeText;
  String? videoLink;
  bool? upiPay;
  bool? qrPay;
  List<Null>? tags;
  String? resetTime;
  int? iV;
  bool? autoDeclare;
  int? transactionBlockDurationHours;
  int? gameOff;
  String? merchantName;
  String? merchantQrUpi;
  String? depositText;
  bool? mainDisplay;
  bool? flatOffer;
  bool? bonusOn;
  String? withdrawalText;

  Data({
    this.deposit,
    this.withdraw,
    this.transfer,
    this.betting,
    this.withdrawlOffDay,
    this.rates,
    this.aviator,
    this.howToPlay,
    this.rules,
    this.rouletteRules,
    this.sId,
    this.name,
    this.referralBonus,
    this.joiningBonus,
    this.merchantUpi,
    this.withdrawOpen,
    this.withdrawClose,
    this.appLink,
    this.webAppLink,
    this.webLink,
    this.shareMessage,
    this.maintainence,
    this.maintainenceMsg,
    this.appVersion,
    this.appVersionReq,
    this.webtoggle,
    this.mobile,
    this.telegram,
    this.autoVerified,
    this.autoNotification,
    this.merchantQr,
    this.whatsapp,
    this.whatsappText,
    this.email1,
    this.email2,
    this.facebook,
    this.twitter,
    this.youtube,
    this.instagram,
    this.privacyPolicy,
    this.welcomeText,
    this.videoLink,
    this.upiPay,
    this.qrPay,
    this.tags,
    this.resetTime,
    this.iV,
    this.autoDeclare,
    this.transactionBlockDurationHours,
    this.gameOff,
    this.merchantName,
    this.merchantQrUpi,
    this.depositText,
    this.mainDisplay,
    this.flatOffer,
    this.bonusOn,
    this.withdrawalText,
  });

  Data.fromJson(Map<String, dynamic> json) {
    deposit =
        json['deposit'] != null ? Deposit.fromJson(json['deposit']) : null;
    withdraw =
        json['withdraw'] != null ? Deposit.fromJson(json['withdraw']) : null;
    transfer =
        json['transfer'] != null ? Deposit.fromJson(json['transfer']) : null;
    betting =
        json['betting'] != null ? Deposit.fromJson(json['betting']) : null;
    withdrawlOffDay = json['withdrawl_off_day'] != null
        ? WithdrawlOffDay.fromJson(json['withdrawl_off_day'])
        : null;
    rates = json['rates'] != null ? Rates.fromJson(json['rates']) : null;
    aviator = json['aviator'] != null
        ? AviatorSettings.fromJson(json['aviator'])
        : null;
    howToPlay = json['how_to_play'];
    rules = json['rules'];
    rouletteRules = json['roulette_rules'];
    sId = json['_id'];
    name = json['name'];
    referralBonus = json['referral_bonus'];
    joiningBonus = json['joining_bonus'];
    merchantUpi = json['merchant_upi'];
    withdrawOpen = json['withdraw_open'];
    withdrawClose = json['withdraw_close'];
    appLink = json['app_link'];
    webAppLink = json['web_app_link'];
    webLink = json['web_link'];
    shareMessage = json['share_message'];
    maintainence = json['maintainence'];
    maintainenceMsg = json['maintainence_msg'];
    appVersion = json['app_version'];
    appVersionReq = json['app_version_req'];
    webtoggle = json['webtoggle'];
    mobile = json['mobile'];
    telegram = json['telegram'];
    autoVerified = json['auto_verified'];
    autoNotification = json['auto_notification'];
    merchantQr = json['merchant_qr'];
    whatsapp = json['whatsapp'];
    whatsappText = json['whatsapp_text'];
    email1 = json['email_1'];
    email2 = json['email_2'];
    facebook = json['facebook'];
    twitter = json['twitter'];
    youtube = json['youtube'];
    instagram = json['instagram'];
    privacyPolicy = json['privacy_policy'];
    welcomeText = json['welcome_text'];
    videoLink = json['video_link'];
    upiPay = json['upi_pay'];
    qrPay = json['qr_pay'];
    resetTime = json['reset_time'];
    iV = json['__v'];
    autoDeclare = json['auto_declare'];
    transactionBlockDurationHours = json['transaction_block_duration_hours'];
    gameOff = json['game_off'];
    merchantName = json['merchant_name'];
    merchantQrUpi = json['merchant_qr_upi'];
    depositText = json['deposit_text'];
    mainDisplay = json['main_display'];
    flatOffer = json['flat_offer'];
    bonusOn = json['bonus_on'];
    withdrawalText = json['withdraw_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (deposit != null) {
      data['deposit'] = deposit!.toJson();
    }
    if (withdraw != null) {
      data['withdraw'] = withdraw!.toJson();
    }
    if (transfer != null) {
      data['transfer'] = transfer!.toJson();
    }
    if (betting != null) {
      data['betting'] = betting!.toJson();
    }
    if (withdrawlOffDay != null) {
      data['withdrawl_off_day'] = withdrawlOffDay!.toJson();
    }
    if (rates != null) {
      data['rates'] = rates!.toJson();
    }
    if (aviator != null) {
      data['aviator'] = aviator!.toJson();
    }
    data['how_to_play'] = howToPlay;
    data['rules'] = rules;
    data['roulette_rules'] = rouletteRules;
    data['_id'] = sId;
    data['name'] = name;
    data['referral_bonus'] = referralBonus;
    data['joining_bonus'] = joiningBonus;
    data['merchant_upi'] = merchantUpi;
    data['withdraw_open'] = withdrawOpen;
    data['withdraw_close'] = withdrawClose;
    data['app_link'] = appLink;
    data['web_app_link'] = webAppLink;
    data['web_link'] = webLink;
    data['share_message'] = shareMessage;
    data['maintainence'] = maintainence;
    data['maintainence_msg'] = maintainenceMsg;
    data['app_version'] = appVersion;
    data['app_version_req'] = appVersionReq;
    data['webtoggle'] = webtoggle;
    data['mobile'] = mobile;
    data['telegram'] = telegram;
    data['auto_verified'] = autoVerified;
    data['auto_notification'] = autoNotification;
    data['merchant_qr'] = merchantQr;
    data['whatsapp'] = whatsapp;
    data['whatsapp_text'] = whatsappText;
    data['email_1'] = email1;
    data['email_2'] = email2;
    data['facebook'] = facebook;
    data['twitter'] = twitter;
    data['youtube'] = youtube;
    data['instagram'] = instagram;
    data['privacy_policy'] = privacyPolicy;
    data['welcome_text'] = welcomeText;
    data['video_link'] = videoLink;
    data['upi_pay'] = upiPay;
    data['qr_pay'] = qrPay;
    data['reset_time'] = resetTime;
    data['__v'] = iV;
    data['auto_declare'] = autoDeclare;
    data['transaction_block_duration_hours'] = transactionBlockDurationHours;
    data['game_off'] = gameOff;
    data['merchant_name'] = merchantName;
    data['merchant_qr_upi'] = merchantQrUpi;
    data['deposit_text'] = depositText;
    data['main_display'] = mainDisplay;
    data['flat_offer'] = flatOffer;
    data['bonus_on'] = bonusOn;
    data['withdraw_text'] = withdrawalText;
    return data;
  }
}

class Deposit {
  int? min;
  int? max;

  Deposit({this.min, this.max});

  Deposit.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['min'] = min;
    data['max'] = max;
    return data;
  }
}

class WithdrawlOffDay {
  bool? monday;
  bool? tuesday;
  bool? wednesday;
  bool? thursday;
  bool? friday;
  bool? saturday;
  bool? sunday;

  WithdrawlOffDay(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday});

  WithdrawlOffDay.fromJson(Map<String, dynamic> json) {
    monday = json['monday'];
    tuesday = json['tuesday'];
    wednesday = json['wednesday'];
    thursday = json['thursday'];
    friday = json['friday'];
    saturday = json['saturday'];
    sunday = json['sunday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['monday'] = monday;
    data['tuesday'] = tuesday;
    data['wednesday'] = wednesday;
    data['thursday'] = thursday;
    data['friday'] = friday;
    data['saturday'] = saturday;
    data['sunday'] = sunday;
    return data;
  }
}

class Rates {
  Main? main;
  Main? starline;
  Galidisawar? galidisawar;
  Roulette? roulette;

  Rates({this.main, this.starline, this.galidisawar, this.roulette});

  Rates.fromJson(Map<String, dynamic> json) {
    main = json['main'] != null ? Main.fromJson(json['main']) : null;
    starline =
        json['starline'] != null ? Main.fromJson(json['starline']) : null;
    galidisawar = json['galidisawar'] != null
        ? Galidisawar.fromJson(json['galidisawar'])
        : null;
    roulette =
        json['roulette'] != null ? Roulette.fromJson(json['roulette']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (main != null) {
      data['main'] = main!.toJson();
    }
    if (starline != null) {
      data['starline'] = starline!.toJson();
    }
    if (galidisawar != null) {
      data['galidisawar'] = galidisawar!.toJson();
    }
    if (roulette != null) {
      data['roulette'] = roulette!.toJson();
    }
    return data;
  }
}

class Main {
  String? singleDigit1;
  String? singleDigit2;
  String? jodiDigit1;
  String? jodiDigit2;
  String? singlePanna1;
  String? singlePanna2;
  String? doublePanna1;
  String? doublePanna2;
  String? tripplePanna1;
  String? tripplePanna2;
  String? halfSangum1;
  String? halfSangum2;
  String? fullSangum1;
  String? fullSangum2;

  Main(
      {this.singleDigit1,
      this.singleDigit2,
      this.jodiDigit1,
      this.jodiDigit2,
      this.singlePanna1,
      this.singlePanna2,
      this.doublePanna1,
      this.doublePanna2,
      this.tripplePanna1,
      this.tripplePanna2,
      this.halfSangum1,
      this.halfSangum2,
      this.fullSangum1,
      this.fullSangum2});

  Main.fromJson(Map<String, dynamic> json) {
    singleDigit1 = json['single_digit_1'];
    singleDigit2 = json['single_digit_2'];
    jodiDigit1 = json['jodi_digit_1'];
    jodiDigit2 = json['jodi_digit_2'];
    singlePanna1 = json['single_panna_1'];
    singlePanna2 = json['single_panna_2'];
    doublePanna1 = json['double_panna_1'];
    doublePanna2 = json['double_panna_2'];
    tripplePanna1 = json['tripple_panna_1'];
    tripplePanna2 = json['tripple_panna_2'];
    halfSangum1 = json['half_sangum_1'];
    halfSangum2 = json['half_sangum_2'];
    fullSangum1 = json['full_sangum_1'];
    fullSangum2 = json['full_sangum_2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['single_digit_1'] = singleDigit1;
    data['single_digit_2'] = singleDigit2;
    data['jodi_digit_1'] = jodiDigit1;
    data['jodi_digit_2'] = jodiDigit2;
    data['single_panna_1'] = singlePanna1;
    data['single_panna_2'] = singlePanna2;
    data['double_panna_1'] = doublePanna1;
    data['double_panna_2'] = doublePanna2;
    data['tripple_panna_1'] = tripplePanna1;
    data['tripple_panna_2'] = tripplePanna2;
    data['half_sangum_1'] = halfSangum1;
    data['half_sangum_2'] = halfSangum2;
    data['full_sangum_1'] = fullSangum1;
    data['full_sangum_2'] = fullSangum2;
    return data;
  }
}

class Galidisawar {
  String? rightDigit1;
  String? rightDigit2;
  String? leftDigit1;
  String? leftDigit2;
  String? jodiDigit1;
  String? jodiDigit2;

  Galidisawar(
      {this.rightDigit1,
      this.rightDigit2,
      this.leftDigit1,
      this.leftDigit2,
      this.jodiDigit1,
      this.jodiDigit2});

  Galidisawar.fromJson(Map<String, dynamic> json) {
    rightDigit1 = json['right_digit_1'];
    rightDigit2 = json['right_digit_2'];
    leftDigit1 = json['left_digit_1'];
    leftDigit2 = json['left_digit_2'];
    jodiDigit1 = json['jodi_digit_1'];
    jodiDigit2 = json['jodi_digit_2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['right_digit_1'] = rightDigit1;
    data['right_digit_2'] = rightDigit2;
    data['left_digit_1'] = leftDigit1;
    data['left_digit_2'] = leftDigit2;
    data['jodi_digit_1'] = jodiDigit1;
    data['jodi_digit_2'] = jodiDigit2;
    return data;
  }
}

class Roulette {
  String? singleDigit1;
  String? singleDigit2;
  String? doubleDigit1;
  String? doubleDigit2;
  String? tripleDigit1;
  String? tripleDigit2;

  Roulette(
      {this.singleDigit1,
      this.singleDigit2,
      this.doubleDigit1,
      this.doubleDigit2,
      this.tripleDigit1,
      this.tripleDigit2});

  Roulette.fromJson(Map<String, dynamic> json) {
    singleDigit1 = json['single_digit_1'];
    singleDigit2 = json['single_digit_2'];
    doubleDigit1 = json['double_digit_1'];
    doubleDigit2 = json['double_digit_2'];
    tripleDigit1 = json['triple_digit_1'];
    tripleDigit2 = json['triple_digit_2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['single_digit_1'] = singleDigit1;
    data['single_digit_2'] = singleDigit2;
    data['double_digit_1'] = doubleDigit1;
    data['double_digit_2'] = doubleDigit2;
    data['triple_digit_1'] = tripleDigit1;
    data['triple_digit_2'] = tripleDigit2;
    return data;
  }
}

// Aviator game settings
class AviatorSettings {
  bool? active;
  bool? maintenance;
  int? minBet;
  int? maxBet;
  int? maxBetPerRound;

  AviatorSettings({
    this.active,
    this.maintenance,
    this.minBet,
    this.maxBet,
    this.maxBetPerRound,
  });

  AviatorSettings.fromJson(Map<String, dynamic> json) {
    active = json['active'];
    maintenance = json['maintenance'];
    minBet = json['minBet'];
    maxBet = json['maxBet'];
    maxBetPerRound = json['maxBetPerRound'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['active'] = active;
    data['maintenance'] = maintenance;
    data['minBet'] = minBet;
    data['maxBet'] = maxBet;
    data['maxBetPerRound'] = maxBetPerRound;
    return data;
  }
}
