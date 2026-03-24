/// PhonePe Configuration File
///
/// This file contains all the configuration settings for PhonePe integration.
/// Replace the placeholder values with your actual PhonePe credentials.
///
/// To get PhonePe credentials:
/// 1. Visit https://business.phonepe.com/
/// 2. Sign up for a merchant account
/// 3. Complete the KYC process
/// 4. Get your Merchant ID, Salt Key, and App ID from the dashboard
library;

class PhonePeConfig {
  // ==================== IMPORTANT ====================
  // Replace these values with your actual PhonePe credentials
  // DO NOT use these placeholder values in production
  // ===================================================

  /// Your PhonePe Merchant ID
  /// Get this from PhonePe Business Dashboard
  static const String merchantId =
      "PGTESTPAYUAT"; // Replace with your merchant ID

  /// Your PhonePe Salt Key
  /// This is used for generating checksums
  /// Keep this secret and secure
  static const String saltKey =
      "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399"; // Replace with your salt key

  /// Salt Index (usually "1")
  static const String saltIndex = "1";

  /// Your PhonePe App ID
  /// Get this from PhonePe Business Dashboard
  static const String appId = ""; // Replace with your app ID

  /// Your app's package name
  /// This should match your app's package name in pubspec.yaml
  static const String packageName =
      "com.example.sm_project"; // Replace with your package name

  // ==================== ENVIRONMENT SETTINGS ====================

  /// Environment: "SANDBOX" for testing, "PRODUCTION" for live
  static const String environment = "SANDBOX";

  /// API Base URLs
  static const String sandboxBaseUrl =
      "https://api-preprod.phonepe.com/apis/pg-sandbox";
  static const String productionBaseUrl = "https://api.phonepe.com/apis/hermes";

  /// Web Payment URLs
  static const String sandboxWebUrl = "https://mercury-t2.phonepe.com/transact";
  static const String productionWebUrl = "https://mercury.phonepe.com/transact";

  // ==================== COMPUTED PROPERTIES ====================

  /// Get the appropriate base URL based on environment
  static String get baseUrl {
    return environment == "PRODUCTION" ? productionBaseUrl : sandboxBaseUrl;
  }

  /// Get the appropriate web URL based on environment
  static String get webUrl {
    return environment == "PRODUCTION" ? productionWebUrl : sandboxWebUrl;
  }

  /// Check if we're in production environment
  static bool get isProduction => environment == "PRODUCTION";

  /// Check if we're in sandbox environment
  static bool get isSandbox => environment == "SANDBOX";

  // ==================== VALIDATION ====================

  /// Validate if all required configuration is set
  static bool get isConfigured {
    return merchantId.isNotEmpty &&
        saltKey.isNotEmpty &&
        appId.isNotEmpty &&
        packageName.isNotEmpty;
  }

  /// Get configuration validation errors
  static List<String> get configurationErrors {
    final errors = <String>[];

    if (merchantId.isEmpty || merchantId == "PGTESTPAYUAT") {
      errors.add("Merchant ID not configured");
    }

    if (saltKey.isEmpty || saltKey == "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399") {
      errors.add("Salt Key not configured");
    }

    if (appId.isEmpty) {
      errors.add("App ID not configured");
    }

    if (packageName.isEmpty || packageName == "com.example.sm_project") {
      errors.add("Package Name not configured");
    }

    return errors;
  }

  // ==================== PAYMENT LIMITS ====================

  /// Minimum payment amount (in rupees)
  static const double minAmount = 1.0;

  /// Maximum payment amount (in rupees)
  static const double maxAmount = 200000.0;

  /// Default callback timeout (in seconds)
  static const int callbackTimeout = 300; // 5 minutes

  // ==================== SUPPORTED PAYMENT METHODS ====================

  /// Supported payment instruments
  static const List<String> supportedPaymentMethods = [
    "PAY_PAGE", // Default payment page with all options
    "UPI_COLLECT", // UPI collect request
    "UPI_QR", // UPI QR code
    "CARD", // Credit/Debit cards
    "NET_BANKING", // Net banking
    "WALLET", // Digital wallets
  ];

  // ==================== HELPER METHODS ====================

  /// Get configuration as a map for debugging
  static Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'environment': environment,
      'baseUrl': baseUrl,
      'webUrl': webUrl,
      'packageName': packageName,
      'isConfigured': isConfigured,
      'configurationErrors': configurationErrors,
    };
  }

  /// Print configuration status (for debugging)
  static void printConfigStatus() {
    print("=== PhonePe Configuration Status ===");
    print("Environment: $environment");
    print("Merchant ID: ${merchantId.isNotEmpty ? 'Set' : 'Not Set'}");
    print("Salt Key: ${saltKey.isNotEmpty ? 'Set' : 'Not Set'}");
    print("App ID: ${appId.isNotEmpty ? 'Set' : 'Not Set'}");
    print("Package Name: $packageName");
    print("Is Configured: $isConfigured");

    if (configurationErrors.isNotEmpty) {
      print("Configuration Errors:");
      for (final error in configurationErrors) {
        print("  - $error");
      }
    }
    print("=====================================");
  }
}

/// PhonePe API Endpoints
class PhonePeEndpoints {
  static const String pay = "/pg/v1/pay";
  static const String status = "/pg/v1/status";
  static const String refund = "/pg/v1/refund";
  static const String refundStatus = "/pg/v1/refund/status";
}

/// PhonePe Response Codes
class PhonePeResponseCodes {
  static const String success = "PAYMENT_SUCCESS";
  static const String pending = "PAYMENT_PENDING";
  static const String failed = "PAYMENT_ERROR";
  static const String cancelled = "PAYMENT_CANCELLED";
  static const String expired = "PAYMENT_EXPIRED";
  static const String declined = "PAYMENT_DECLINED";
}

/// PhonePe Error Codes
class PhonePeErrorCodes {
  static const String invalidRequest = "BAD_REQUEST";
  static const String unauthorized = "UNAUTHORIZED";
  static const String forbidden = "FORBIDDEN";
  static const String notFound = "NOT_FOUND";
  static const String internalError = "INTERNAL_SERVER_ERROR";
  static const String gatewayTimeout = "GATEWAY_TIMEOUT";
  static const String tooManyRequests = "TOO_MANY_REQUESTS";
}

/// PhonePe Configuration Instructions
class PhonePeSetupInstructions {
  static const String instructions = '''
=== PhonePe Integration Setup Instructions ===

1. GET PHONEPE CREDENTIALS:
   - Visit https://business.phonepe.com/
   - Sign up for a merchant account
   - Complete KYC verification
   - Get Merchant ID, Salt Key, and App ID from dashboard

2. UPDATE CONFIGURATION:
   - Open lib/features/phone_pe/phone_pe_config.dart
   - Replace placeholder values with your actual credentials
   - Set environment to "SANDBOX" for testing, "PRODUCTION" for live

3. ANDROID SETUP:
   - Add PhonePe app package to android/app/src/main/AndroidManifest.xml
   - Add internet permission if not already present

4. IOS SETUP:
   - Add PhonePe URL scheme to ios/Runner/Info.plist
   - Add App Transport Security settings if needed

5. BACKEND SETUP:
   - Implement webhook endpoint for payment status callbacks
   - Verify payment status using PhonePe status API
   - Handle payment success/failure scenarios

6. TESTING:
   - Use sandbox environment for testing
   - Test with small amounts first
   - Verify callback handling

7. PRODUCTION:
   - Switch to production environment
   - Update credentials with production values
   - Test thoroughly before going live

For detailed documentation, visit:
https://developer.phonepe.com/docs/

==============================================
''';

  static void printInstructions() {
    print(instructions);
  }
}
