import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'phone_pe_screen.dart';
import 'phone_pe_service.dart';
import 'phone_pe_webview.dart';

class PhonePeDemo extends StatefulWidget {
  const PhonePeDemo({super.key});

  @override
  State<PhonePeDemo> createState() => _PhonePeDemoState();
}

class _PhonePeDemoState extends State<PhonePeDemo> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: "100.00");
  final _merchantIdController = TextEditingController(text: "PGTESTPAYUAT");
  final _callbackUrlController =
      TextEditingController(text: "https://webhook.site/callback");
  final _userIdController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  bool _useWebView = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _merchantIdController.dispose();
    _callbackUrlController.dispose();
    _userIdController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _generateTransactionId() {
    return PhonePeService.generateTransactionId();
  }

  Future<void> _startPayment() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || !PhonePeService.isValidAmount(amount)) {
      _showSnackBar("Please enter a valid amount (₹1 - ₹2,00,000)", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionId = _generateTransactionId();

      if (_useWebView) {
        // Use WebView integration
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => PhonePeWebView(
              amount: amount,
              merchantId: _merchantIdController.text,
              merchantTransactionId: transactionId,
              callbackUrl: _callbackUrlController.text,
              userId: _userIdController.text.isEmpty
                  ? null
                  : _userIdController.text,
              mobileNumber: _mobileController.text.isEmpty
                  ? null
                  : _mobileController.text,
              email:
                  _emailController.text.isEmpty ? null : _emailController.text,
            ),
          ),
        );

        if (result != null) {
          _handlePaymentResult(result);
        }
      } else {
        // Use SDK integration
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PhonePeScreen(
              amount: amount,
              merchantId: _merchantIdController.text,
              merchantTransactionId: transactionId,
              callbackUrl: _callbackUrlController.text,
              userId: _userIdController.text.isEmpty
                  ? null
                  : _userIdController.text,
            ),
          ),
        );

        if (result != null) {
          _handleSDKResult(result);
        }
      }
    } catch (e) {
      _showSnackBar("Error starting payment: $e", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handlePaymentResult(Map<String, dynamic> result) {
    final status = result['status']?.toString().toLowerCase();
    final transactionId = result['transactionId'];
    final amount = result['amount'];

    String message;
    Color color;

    switch (status) {
      case 'success':
        message = "Payment successful! Transaction ID: $transactionId";
        color = Colors.green;
        break;
      case 'pending':
        message = "Payment is pending verification";
        color = Colors.orange;
        break;
      default:
        message = "Payment failed or was cancelled";
        color = Colors.red;
    }

    _showSnackBar(message, color);
  }

  void _handleSDKResult(bool success) {
    final message = success
        ? "Payment completed successfully!"
        : "Payment failed or was cancelled";
    final color = success ? Colors.green : Colors.red;

    _showSnackBar(message, color);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PhonePe Integration Demo"),
        backgroundColor: const Color(0xFF5f259f),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5f259f), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 20),
                  _buildPaymentDetailsCard(),
                  const SizedBox(height: 20),
                  _buildMerchantDetailsCard(),
                  const SizedBox(height: 20),
                  _buildOptionalDetailsCard(),
                  const SizedBox(height: 20),
                  _buildIntegrationTypeCard(),
                  const SizedBox(height: 30),
                  _buildPaymentButton(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8F9FA)],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF5f259f),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.payment,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "PhonePe Payment Gateway",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5f259f),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Secure and fast payments with PhonePe",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                color: Color(0xFF5f259f),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Amount (₹)",
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter amount";
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return "Please enter valid amount";
                }
                if (amount > 200000) {
                  return "Amount cannot exceed ₹2,00,000";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Merchant Configuration",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5f259f),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _merchantIdController,
              decoration: const InputDecoration(
                labelText: "Merchant ID",
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
                helperText: "Use PGTESTPAYUAT for testing",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter merchant ID";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _callbackUrlController,
              decoration: const InputDecoration(
                labelText: "Callback URL",
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
                helperText: "URL to receive payment status",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter callback URL";
                }
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.hasAbsolutePath) {
                  return "Please enter valid URL";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalDetailsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Optional Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5f259f),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: "User ID (Optional)",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: "Mobile Number (Optional)",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!PhonePeService.isValidMobileNumber(value)) {
                    return "Please enter valid mobile number";
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email (Optional)",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!PhonePeService.isValidEmail(value)) {
                    return "Please enter valid email";
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationTypeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Integration Type",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5f259f),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title:
                  Text(_useWebView ? "WebView Integration" : "SDK Integration"),
              subtitle: Text(
                _useWebView
                    ? "Uses web-based payment flow"
                    : "Uses native PhonePe SDK",
              ),
              value: _useWebView,
              onChanged: (value) {
                setState(() {
                  _useWebView = value;
                });
              },
              activeColor: const Color(0xFF5f259f),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _startPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5f259f),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text("Processing..."),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment, size: 24),
                  SizedBox(width: 12),
                  Text(
                    "Start Payment",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF5f259f)),
                SizedBox(width: 8),
                Text(
                  "Important Notes",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5f259f),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "• Replace configuration values with your actual PhonePe credentials\n"
              "• Use SANDBOX environment for testing\n"
              "• Implement proper backend verification for production\n"
              "• Handle payment status callbacks securely\n"
              "• Test with small amounts first",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This is a demo implementation. Update salt keys and merchant details before production use.",
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
