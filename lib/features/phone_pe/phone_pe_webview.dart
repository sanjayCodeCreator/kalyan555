import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PhonePeWebView extends StatefulWidget {
  final double amount;
  final String merchantId;
  final String merchantTransactionId;
  final String callbackUrl;
  final String? userId;
  final String? mobileNumber;
  final String? email;

  const PhonePeWebView({
    super.key,
    required this.amount,
    required this.merchantId,
    required this.merchantTransactionId,
    required this.callbackUrl,
    this.userId,
    this.mobileNumber,
    this.email,
  });

  @override
  State<PhonePeWebView> createState() => _PhonePeWebViewState();
}

class _PhonePeWebViewState extends State<PhonePeWebView> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;
  double _loadingProgress = 0.0;

  // PhonePe Web Configuration
  static const String _saltKey =
      "YOUR_SALT_KEY"; // Replace with your actual salt key
  static const String _saltIndex = "1";
  static const String _baseUrl =
      "https://api-preprod.phonepe.com/apis/pg-sandbox"; // Sandbox URL
  static const String _webPaymentUrl =
      "https://mercury-t2.phonepe.com/transact";

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _handleUrlChange(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = "Web error: ${error.description}";
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadPaymentPage();
  }

  String _generateChecksum(String payload) {
    const key = _saltKey + _saltIndex;
    final bytes = utf8.encode("$payload/pg/v1/pay$key");
    final digest = sha256.convert(bytes);
    return "$digest###$_saltIndex";
  }

  void _loadPaymentPage() {
    try {
      // Create payment payload
      final paymentPayload = {
        "merchantId": widget.merchantId,
        "merchantTransactionId": widget.merchantTransactionId,
        "merchantUserId": widget.userId ?? "USER_${Random().nextInt(999999)}",
        "amount": (widget.amount * 100).toInt(), // Amount in paise
        "redirectUrl": widget.callbackUrl,
        "redirectMode": "REDIRECT",
        "callbackUrl": widget.callbackUrl,
        "mobileNumber": widget.mobileNumber ?? "9999999999",
        "paymentInstrument": {"type": "PAY_PAGE"},
        if (widget.email != null) "email": widget.email,
      };

      final payloadString =
          base64Encode(utf8.encode(jsonEncode(paymentPayload)));
      final checksum = _generateChecksum(payloadString);

      // Create HTML form for auto-submission
      final htmlContent = _createPaymentForm(payloadString, checksum);

      _webViewController.loadHtmlString(htmlContent);
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load payment page: $e";
        _isLoading = false;
      });
    }
  }

  String _createPaymentForm(String payload, String checksum) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>PhonePe Payment</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                margin: 0;
                padding: 20px;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
            }
            .container {
                background: white;
                border-radius: 12px;
                padding: 30px;
                box-shadow: 0 10px 30px rgba(0,0,0,0.2);
                text-align: center;
                max-width: 400px;
                width: 100%;
            }
            .logo {
                width: 80px;
                height: 80px;
                background: #5f259f;
                border-radius: 50%;
                margin: 0 auto 20px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 24px;
                font-weight: bold;
            }
            .amount {
                font-size: 32px;
                font-weight: bold;
                color: #333;
                margin: 20px 0;
            }
            .details {
                background: #f8f9fa;
                border-radius: 8px;
                padding: 15px;
                margin: 20px 0;
                text-align: left;
            }
            .detail-row {
                display: flex;
                justify-content: space-between;
                margin: 8px 0;
                font-size: 14px;
            }
            .detail-label {
                color: #666;
            }
            .detail-value {
                font-weight: 500;
                color: #333;
            }
            .pay-button {
                background: #5f259f;
                color: white;
                border: none;
                padding: 15px 30px;
                border-radius: 8px;
                font-size: 16px;
                font-weight: bold;
                cursor: pointer;
                width: 100%;
                margin-top: 20px;
                transition: background 0.3s;
            }
            .pay-button:hover {
                background: #4a1d7a;
            }
            .loading {
                display: none;
                margin-top: 20px;
            }
            .spinner {
                border: 3px solid #f3f3f3;
                border-top: 3px solid #5f259f;
                border-radius: 50%;
                width: 30px;
                height: 30px;
                animation: spin 1s linear infinite;
                margin: 0 auto;
            }
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="logo">Pe</div>
            <h2>PhonePe Payment</h2>
            <div class="amount">₹${widget.amount.toStringAsFixed(2)}</div>
            
            <div class="details">
                <div class="detail-row">
                    <span class="detail-label">Merchant ID:</span>
                    <span class="detail-value">${widget.merchantId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Transaction ID:</span>
                    <span class="detail-value">${widget.merchantTransactionId}</span>
                </div>
                ${widget.mobileNumber != null ? '''
                <div class="detail-row">
                    <span class="detail-label">Mobile:</span>
                    <span class="detail-value">${widget.mobileNumber}</span>
                </div>
                ''' : ''}
            </div>

            <form id="paymentForm" action="$_baseUrl/pg/v1/pay" method="POST">
                <input type="hidden" name="request" value="$payload">
                <input type="hidden" name="X-VERIFY" value="$checksum">
                <button type="button" class="pay-button" onclick="submitPayment()">
                    Pay with PhonePe
                </button>
            </form>

            <div class="loading" id="loading">
                <div class="spinner"></div>
                <p>Redirecting to PhonePe...</p>
            </div>
        </div>

        <script>
            function submitPayment() {
                document.getElementById('loading').style.display = 'block';
                document.querySelector('.pay-button').style.display = 'none';
                
                setTimeout(function() {
                    document.getElementById('paymentForm').submit();
                }, 1000);
            }
        </script>
    </body>
    </html>
    ''';
  }

  void _handleUrlChange(String url) {
    // Handle callback URL
    if (url.contains(widget.callbackUrl) ||
        url.contains('callback') ||
        url.contains('return')) {
      _handlePaymentCallback(url);
    }

    // Handle PhonePe specific URLs
    if (url.contains('phonepe.com') && url.contains('status')) {
      _extractPaymentStatus(url);
    }
  }

  void _handlePaymentCallback(String url) {
    try {
      final uri = Uri.parse(url);
      final queryParams = uri.queryParameters;

      // Extract payment status from URL parameters
      final status = queryParams['status'] ?? queryParams['code'];
      final transactionId =
          queryParams['transactionId'] ?? queryParams['merchantTransactionId'];

      if (status != null) {
        _showPaymentResult(status, transactionId);
      }
    } catch (e) {
      print("Error handling callback: $e");
    }
  }

  void _extractPaymentStatus(String url) {
    // This method can be used to extract status from PhonePe URLs
    // Implementation depends on PhonePe's URL structure
    print("PhonePe URL: $url");
  }

  void _showPaymentResult(String status, String? transactionId) {
    final isSuccess = status.toLowerCase() == 'success';
    final isPending = status.toLowerCase() == 'pending';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle
                  : isPending
                      ? Icons.pending
                      : Icons.error,
              color: isSuccess
                  ? Colors.green
                  : isPending
                      ? Colors.orange
                      : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess
                  ? "Payment Successful"
                  : isPending
                      ? "Payment Pending"
                      : "Payment Failed",
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: ${status.toUpperCase()}"),
            if (transactionId != null) Text("Transaction ID: $transactionId"),
            Text("Amount: ₹${widget.amount.toStringAsFixed(2)}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop({
                'status': status,
                'transactionId': transactionId,
                'amount': widget.amount,
              });
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PhonePe Payment"),
        backgroundColor: const Color(0xFF5f259f),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController.reload();
            },
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

    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5f259f)),
                ),
                const SizedBox(height: 16),
                const Text("Loading PhonePe Payment..."),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF5f259f)),
                ),
              ],
            ),
          ),
      ],
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
                _loadPaymentPage();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5f259f),
                foregroundColor: Colors.white,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}
