import 'dart:math';

import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/payment/smepay/model/sme_pay_start_response.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:url_launcher/url_launcher.dart';

class SmepayScreen extends ConsumerStatefulWidget {
  const SmepayScreen({super.key});

  @override
  ConsumerState<SmepayScreen> createState() => _SmepayScreenState();
}

class _SmepayScreenState extends ConsumerState<SmepayScreen> {
  final _amountController = TextEditingController(text: '300');
  bool _loading = false;
  SmePayStartResponse? _result;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _generateOrderId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(900000) + 100000;
    return '$millis$rnd';
  }

  Future<void> _startPayment() async {
    FocusScope.of(context).unfocus();
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      _showSnack('Enter amount');
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
    });
    final orderId = _generateOrderId();
    await ref
        .read(getParticularPlayerNotifierProvider.notifier)
        .getParticularPlayerModel();
    final api = ApiService();
    final res = await api.startSmePayTransaction(
      amount: amount,
      orderId: orderId,
      userId: ref
              .watch(getParticularPlayerNotifierProvider)
              .value
              ?.getParticularPlayerModel
              ?.data
              ?.sId ??
          "",
    );
    final data = res?.data;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Select Payment Method"),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _upiButton('BHIM UPI', Icons.account_balance_wallet_rounded,
                        () => _launchUri(data?.link?.bhim), theme),
                    _upiButton('PhonePe', Icons.phone_android_rounded,
                        () => _launchUri(data?.link?.phonepe), theme),
                    _upiButton('Paytm', Icons.payment_rounded,
                        () => _launchUri(data?.link?.paytm), theme),
                    _upiButton('Google Pay', Icons.payments_rounded,
                        () => _launchUri(data?.link?.gpay), theme),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        );
      },
    );
    setState(() {
      _loading = false;
      _result = res;
    });
    if (res == null) {
      _showSnack('Payment order failed');
    } else if (res.status.toLowerCase() != 'success') {
      _showSnack(res.message);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _launchUri(String? uri) async {
    if (uri == null || uri.isEmpty) {
      _showSnack('Link not available');
      return;
    }
    final parsed = Uri.parse(uri);
    context.pop();
    final launched = await canLaunchUrl(parsed)
        ? await launchUrl(parsed, mode: LaunchMode.externalApplication)
        : false;
    if (!launched) {
      _showSnack('Cannot open: $uri');
      return;
    }
    // After launching UPI app, call create_transaction as instructed
    try {
      final amountText = _amountController.text.trim();
      final amountVal = int.tryParse(amountText) ?? 0;
      if (amountVal <= 0) return;
      // Use slug from start response if available, else fallback to generated order id marker
      final slug = _result?.slug ?? 'UNKNOWN';
      final api = ApiService();
      await ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();
      await api.postCreateTransaction({
        "user_id": ref
                .watch(getParticularPlayerNotifierProvider)
                .value
                ?.getParticularPlayerModel
                ?.data
                ?.sId ??
            "",
        "amount": amountVal,
        "transfer_type": "provider",
        "type": "mobile",
        "note": "Test deposit transaction",
        "status": "completed",
        "order_slug": slug,
      });
    } catch (e) {
      // swallow silently but log UI toast
      _showSnack('Transaction recorded call failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.primary.withOpacity(0.08), cs.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _HeaderCard(
                  child: Row(
                    children: [
                      Icon(Icons.qr_code_2_rounded,
                          size: 36, color: cs.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Instant UPI Collection',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const _InfoBadge(text: 'Secure'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _AmountCard(
                  controller: _amountController,
                  loading: _loading,
                  onSubmit: _startPayment,
                ),

                const SizedBox(height: 10),
                // AnimatedSwitcher(
                //   duration: const Duration(milliseconds: 250),
                //   child: _loading
                //       ? const Center(child: CircularProgressIndicator())
                //       : _buildResult(theme),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildResult(ThemeData theme) {
  //   final cs = theme.colorScheme;
  //   final data = _result?.data;
  //   if (data == null) {
  //     return SizedBox();
  //   }
  //   return SingleChildScrollView(
  //     key: const ValueKey('result'),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: [
  //         _SectionTitle('Pay using'),
  //         Wrap(
  //           spacing: 12,
  //           runSpacing: 12,
  //           children: [
  //             _upiButton('BHIM UPI', Icons.account_balance_wallet_rounded,
  //                 () => _launchUri(data.link?.bhim), theme),
  //             _upiButton('PhonePe', Icons.phone_android_rounded,
  //                 () => _launchUri(data.link?.phonepe), theme),
  //             _upiButton('Paytm', Icons.payment_rounded,
  //                 () => _launchUri(data.link?.paytm), theme),
  //             _upiButton('Google Pay', Icons.payments_rounded,
  //                 () => _launchUri(data.link?.gpay), theme),
  //           ],
  //         ),
  //         const SizedBox(height: 8),
  //       ],
  //     ),
  //   );
  // }

  Widget _upiButton(
      String label, IconData icon, VoidCallback onPressed, ThemeData theme) {
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.primary),
            const SizedBox(width: 8),
            Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            const Icon(Icons.north_east_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountGrid extends StatelessWidget {
  const _QuickAmountGrid({
    required this.amounts,
    required this.onSelect,
  });

  final List<String> amounts;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 2.0,
      ),
      itemCount: amounts.length,
      itemBuilder: (context, index) {
        final amt = amounts[index];
        return InkWell(
          onTap: () => onSelect(amt),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                amt,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cs.primary.withOpacity(0.15)),
      ),
      child: child,
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.controller,
    required this.loading,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: cs.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.currency_rupee_rounded, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _QuickAmountGrid(
            amounts: const ['300', '500', '1000', '2000', '5000', '10000'],
            onSelect: (val) {
              controller.text = val;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: loading ? null : onSubmit,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                    ),
              label: Text(
                loading ? 'Creating Order...' : 'Pay Now',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSecondaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: cs.onSurface.withOpacity(0.7))),
                const SizedBox(height: 4),
                Text(value,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final fg = (color ?? cs.primary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: fg.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: theme.textTheme.labelMedium?.copyWith(color: fg)),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }
}
