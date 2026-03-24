class APIConstants {
  static const String websiteUrl = "https://madhavmatkaapp.online/";
  // static const String baseUrl = "http://192.168.0.8:5002/api/v1/";
  // static const String baseUrl = "http://192.168.0.8:2552/api/v1/";
  static const String baseUrl = "https://server.kalyanliveapp.online/api/v1/";
  // static const String baseUrl = "http://localhost:2552/api/v1/";
  static const String apiBaseUrl = "${baseUrl}user/";

  static const String chatSocketUrl =
      'https://server.matkaaplaygames.com/api/v1/aviator';

  static const connectionTimeOut = 300000;
  static const receiveTimeOut = 300000;

  /// API Requests

  /// Auth Part
  static const String registerrequestAPI = "signup";
  static const String sendAPI = "send";
  static const String verifyAPI = "verify";
  static const String loginAPI = "loginpass";
  static const String loginMpinApi = "loginpin";
  static const String loginPass = "loginPass";
  static const String createPasswordApi = "forgotpass";
  static const String changePassword = "changepassword";
  static const String createNewPinApi = "forgotpin";

  static const String getParticularPlayer = "get";
  static const String getAllMarket = "all";
  static const String betGamearray = "array";

  static const String getSetting = "get";
  static const String profileUpdate = "update";
  static const String createTransaction = "create_transaction";
  static const String getTransactionHistory = "get";
  static const String allowNotification = "switch";
  static const String contactPublicLinks = "public/link";
  static const String getAllNotices = "notices/all";
  static const String allMobileTransaction = "all_mobile";
  static const String smePayStart = "transaction/start";
  static const String getTodayWinners = "today/winners";
}
