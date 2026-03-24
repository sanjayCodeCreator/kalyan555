import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PhonePeService {
  // Configuration constants - Replace with your actual values
  static const String _saltKey = "YOUR_SALT_KEY_HERE";
  static const String _saltIndex = "1";
  static const String _merchantId = "YOUR_MERCHANT_ID";
  static const String _appId = "YOUR_APP_ID";
  static const String _packageName = "com.example.yourapp";

  // Environment settings
  static const String _environment = "SANDBOX"; // Use "PRODUCTION" for live
  static const String _baseUrl =
      "https://api-preprod.phonepe.com/apis/pg-sandbox"; // Sandbox URL

  static bool _isInitialized = false;

  /// Initialize PhonePe SDK
  static Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      _isInitialized = true;
      return true;
    } catch (e) {
      print("PhonePe initialization failed: $e");
      return false;
    }
  }

  /// Generate unique transaction ID
  static String generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return "TXN_${timestamp}_$random";
  }

  /// Generate checksum for payment request
  static String generateChecksum(String payload, String endpoint) {
    const key = _saltKey + _saltIndex;
    final stringToHash = payload + endpoint + key;
    final bytes = utf8.encode(stringToHash);
    final digest = sha256.convert(bytes);
    return "${digest.toString()}###$_saltIndex";
  }

  /// Create payment payload
  static Map<String, dynamic> createPaymentPayload({
    required String merchantTransactionId,
    required double amount,
    required String callbackUrl,
    String? userId,
    String? mobileNumber,
    String? email,
    Map<String, dynamic>? additionalData,
  }) {
    return {
      "merchantId": _merchantId,
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": userId ?? "USER_${Random().nextInt(999999)}",
      "amount": (amount * 100).toInt(), // Convert to paise
      "redirectUrl": callbackUrl,
      "redirectMode": "POST",
      "callbackUrl": callbackUrl,
      "mobileNumber": mobileNumber ?? "9999999999",
      "paymentInstrument": {"type": "PAY_PAGE"},
      if (email != null) "email": email,
      if (additionalData != null) ...additionalData,
    };
  }

  /// Start payment transaction
  static Future<Map<String, dynamic>> startPayment({
    required String merchantTransactionId,
    required double amount,
    required String callbackUrl,
    String? userId,
    String? mobileNumber,
    String? email,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      if (!_isInitialized) {
        final initialized = await initialize();
        if (!initialized) {
          return {
            'status': 'ERROR',
            'message': 'Failed to initialize PhonePe SDK'
          };
        }
      }

      // Create payment payload
      final paymentPayload = createPaymentPayload(
        merchantTransactionId: merchantTransactionId,
        amount: amount,
        callbackUrl: callbackUrl,
        userId: userId,
        mobileNumber: mobileNumber,
        email: email,
        additionalData: additionalData,
      );

      // Encode payload
      final payloadString =
          base64Encode(utf8.encode(jsonEncode(paymentPayload)));

      // Generate checksum
      final checksum = generateChecksum(payloadString, "/pg/v1/pay");

      // Start transaction
      const response = null;

      return _processPaymentResponse(response);
    } catch (e) {
      return {'status': 'ERROR', 'message': 'Payment failed: $e'};
    }
  }

  /// Process payment response
  static Map<String, dynamic> _processPaymentResponse(dynamic response) {
    if (response == null) {
      return {
        'status': 'ERROR',
        'message': 'No response received from PhonePe'
      };
    }

    final status = response['status']?.toString().toUpperCase();
    final data = response['data'];

    switch (status) {
      case 'SUCCESS':
        return {
          'status': 'SUCCESS',
          'message': 'Payment completed successfully',
          'data': data,
          'transactionId': data?['transactionId'],
          'merchantTransactionId': data?['merchantTransactionId'],
        };

      case 'FAILURE':
        return {
          'status': 'FAILURE',
          'message': data?['error'] ?? 'Payment failed',
          'data': data,
          'errorCode': data?['code'],
        };

      case 'PENDING':
        return {
          'status': 'PENDING',
          'message': 'Payment is pending verification',
          'data': data,
        };

      default:
        return {
          'status': 'CANCELLED',
          'message': 'Payment was cancelled by user',
          'data': data,
        };
    }
  }

  /// Check payment status (requires backend API call)
  static Future<Map<String, dynamic>> checkPaymentStatus(
      String merchantTransactionId) async {
    try {
      // This would typically involve calling your backend API
      // which then calls PhonePe's status check API

      // For now, return a placeholder response
      return {
        'status': 'PENDING',
        'message': 'Status check requires backend implementation'
      };
    } catch (e) {
      return {
        'status': 'ERROR',
        'message': 'Failed to check payment status: $e'
      };
    }
  }

  /// Validate payment amount
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= 200000; // PhonePe limit is ₹2,00,000
  }

  /// Validate mobile number
  static bool isValidMobileNumber(String? mobileNumber) {
    if (mobileNumber == null || mobileNumber.isEmpty) return false;
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(mobileNumber);
  }

  /// Validate email
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Get configuration info
  static Map<String, String> getConfiguration() {
    return {
      'environment': _environment,
      'merchantId': _merchantId,
      'appId': _appId,
      'packageName': _packageName,
      'baseUrl': _baseUrl,
    };
  }

  /// Format amount for display
  static String formatAmount(double amount) {
    return "₹${amount.toStringAsFixed(2)}";
  }

  /// Generate QR code data for UPI payments (if needed)
  static String generateUPIString({
    required String merchantId,
    required String merchantTransactionId,
    required double amount,
    String? note,
  }) {
    const upiId = "phonepe@ybl"; // PhonePe UPI ID
    final amountStr = amount.toStringAsFixed(2);

    return "upi://pay?pa=$upiId&pn=PhonePe&mc=0000&tid=$merchantTransactionId&tr=$merchantTransactionId&tn=${note ?? 'Payment'}&am=$amountStr&cu=INR";
  }
}

/// Payment result model
class PhonePePaymentResult {
  final String status;
  final String message;
  final String? transactionId;
  final String? merchantTransactionId;
  final Map<String, dynamic>? data;
  final String? errorCode;

  PhonePePaymentResult({
    required this.status,
    required this.message,
    this.transactionId,
    this.merchantTransactionId,
    this.data,
    this.errorCode,
  });

  bool get isSuccess => status == 'SUCCESS';
  bool get isFailure => status == 'FAILURE';
  bool get isPending => status == 'PENDING';
  bool get isCancelled => status == 'CANCELLED';
  bool get isError => status == 'ERROR';

  factory PhonePePaymentResult.fromMap(Map<String, dynamic> map) {
    return PhonePePaymentResult(
      status: map['status'] ?? 'ERROR',
      message: map['message'] ?? 'Unknown error',
      transactionId: map['transactionId'],
      merchantTransactionId: map['merchantTransactionId'],
      data: map['data'],
      errorCode: map['errorCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'message': message,
      'transactionId': transactionId,
      'merchantTransactionId': merchantTransactionId,
      'data': data,
      'errorCode': errorCode,
    };
  }

  @override
  String toString() {
    return 'PhonePePaymentResult(status: $status, message: $message, transactionId: $transactionId)';
  }
}
