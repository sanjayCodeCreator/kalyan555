import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PhonePeScreen extends StatefulWidget {
  final double amount;
  final String merchantId;
  final String merchantTransactionId;
  final String callbackUrl;
  final String? userId;

  const PhonePeScreen({
    super.key,
    required this.amount,
    required this.merchantId,
    required this.merchantTransactionId,
    required this.callbackUrl,
    this.userId,
  });

  @override
  State<PhonePeScreen> createState() => _PhonePeScreenState();
}

class _PhonePeScreenState extends State<PhonePeScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _isPhonePeInitialized = false;
  String? _paymentUrl;
  String? _errorMessage;

  // PhonePe Configuration
  static const String _saltKey =
      "YOUR_SALT_KEY"; // Replace with your actual salt key
  static const String _saltIndex = "1"; // Replace with your salt index
  static const String _environment = "SANDBOX"; // Use "PRODUCTION" for live
  static const String _appId = "YOUR_APP_ID"; // Replace with your app ID
  static const String _packageName =
      "YOUR_PACKAGE_NAME"; // Replace with your package name

  @override
  void initState() {
    super.initState();
    _initializePhonePe();
  }

  Future<void> _initializePhonePe() async {
    try {
      setState(() {
        _isPhonePeInitialized = true;
      });
      _initiatePayment();
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to initialize PhonePe: $e";
        _isLoading = false;
      });
    }
  }

  String _generateChecksum(String payload) {
    const key = _saltKey + _saltIndex;
    final bytes = utf8.encode("$payload/pg/v1/pay$key");
    final digest = sha256.convert(bytes);
    return "$digest###$_saltIndex";
  }

  Future<void> _initiatePayment() async {
    try {
      // Create payment payload
      final paymentPayload = {
        "merchantId": widget.merchantId,
        "merchantTransactionId": widget.merchantTransactionId,
        "merchantUserId": widget.userId ?? "USER_${Random().nextInt(999999)}",
        "amount": (widget.amount * 100).toInt(), // Amount in paise
        "redirectUrl": widget.callbackUrl,
        "redirectMode": "POST",
        "callbackUrl": widget.callbackUrl,
        "mobileNumber": "9999999999", // Optional
        "paymentInstrument": {"type": "PAY_PAGE"}
      };

      final payloadString =
          base64Encode(utf8.encode(jsonEncode(paymentPayload)));
      final checksum = _generateChecksum(payloadString);

      // Start payment transaction
      const response = null;

      _handlePaymentResponse(response);
    } catch (e) {
      setState(() {
        _errorMessage = "Payment initiation failed: $e";
        _isLoading = false;
      });
    }
  }

  void _handlePaymentResponse(dynamic response) {
    setState(() {
      _isLoading = false;
    });

    if (response != null) {
      final status = response['status'];
      final data = response['data'];

      switch (status) {
        case 'SUCCESS':
          _showPaymentResult(
            true,
            "Payment Successful!",
            "Transaction ID: ${widget.merchantTransactionId}",
          );
          break;
        case 'FAILURE':
          _showPaymentResult(
            false,
            "Payment Failed",
            data?['error'] ?? "Unknown error occurred",
          );
          break;
        case 'PENDING':
          _showPaymentResult(
            null,
            "Payment Pending",
            "Please check your transaction status",
          );
          break;
        default:
          _showPaymentResult(
            false,
            "Payment Cancelled",
            "Transaction was cancelled by user",
          );
      }
    } else {
      _showPaymentResult(
        false,
        "Payment Failed",
        "No response received from PhonePe",
      );
    }
  }

  void _showPaymentResult(bool? success, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success == true
                  ? Icons.check_circle
                  : success == false
                      ? Icons.error
                      : Icons.pending,
              color: success == true
                  ? Colors.green
                  : success == false
                      ? Colors.red
                      : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(success);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus() async {
    try {
      // You can implement payment status check here
      // This would typically involve calling your backend API
      // to verify the payment status with PhonePe

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Checking payment status..."),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error checking status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PhonePe Payment"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPaymentStatus,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    return _buildPaymentWidget();
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          SizedBox(height: 16),
          Text(
            "Initializing PhonePe Payment...",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              "Payment Error",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
                _initializePhonePe();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Payment Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      "Amount", "₹${widget.amount.toStringAsFixed(2)}"),
                  _buildDetailRow("Merchant ID", widget.merchantId),
                  _buildDetailRow(
                      "Transaction ID", widget.merchantTransactionId),
                  if (widget.userId != null)
                    _buildDetailRow("User ID", widget.userId!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Payment Status",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                SizedBox(height: 8),
                Text(
                  "PhonePe SDK Initialized",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Ready to process payments",
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _initiatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Pay with PhonePe",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
