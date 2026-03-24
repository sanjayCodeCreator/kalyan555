import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/features/drawer/saved_bank_account.dart';
import 'package:sm_project/features/home/deposit_funds.dart';
import 'package:sm_project/features/home/qr_history_screen.dart';
import 'package:sm_project/features/home/upi_history_screen.dart';
import 'package:sm_project/features/home/withdrawal_history_screen.dart';
import 'package:sm_project/features/home/withdrawal_screen.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../../utils/customization.dart';

class FundScreen extends StatelessWidget {
  const FundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors chosen to closely match the provided screenshot
    const Color headerTeal = Color(0xFF0F7E80);
    const Color headerTealDark = Color(0xFF0B6A6B);
    const Color pageBackground = Color(0xFFF3F5F7);

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: headerTeal,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '${Customization.appname}',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildTicketTile(
              context: context,
              title: 'Add Fund',
              subtitle: 'You can add fund to your wallet',
              icon: Icons.upload_rounded,
              iconBackground: headerTeal,
              stubColor: const Color(0xFFE7EBF0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Deposit()),
                );
              },
            ),
            _buildTicketTile(
              context: context,
              title: 'Withdraw Fund',
              subtitle: 'You can withdraw winnings',
              icon: Icons.download_rounded,
              iconBackground: Colors.red.shade600,
              stubColor: const Color(0xFFE7EBF0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Withdrawal()),
                );
              },
            ),
            _buildTicketTile(
              context: context,
              title: 'Add Bank Details',
              subtitle: 'You can add your bank details for withdrawal',
              icon: Icons.account_balance_outlined,
              iconBackground: Colors.teal.shade700,
              stubColor: const Color(0xFFE7EBF0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedBankAccount()),
                );
              },
            ),
            _buildTicketTile(
              context: context,
              title: 'Deposit History',
              subtitle: 'You can see you deposit history here',
              icon: Icons.receipt_long_outlined,
              iconBackground: Colors.indigo.shade600,
              stubColor: const Color(0xFFE7EBF0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QrHistoryScreen()),
                );
              },
            ),
            _buildTicketTile(
              context: context,
              title: 'Withdrawal History',
              subtitle: 'You can see history of your withdrawal',
              icon: Icons.history_outlined,
              iconBackground: Colors.blue.shade600,
              stubColor: const Color(0xFFE7EBF0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const WithdrawalHistoryScreen()),
                );
              },
            ),
            _buildTicketTile(
              context: context,
              title: 'Fund Request History',
              subtitle: 'You can see history of your deposit/withdrawal',
              icon: Icons.request_quote_outlined,
              iconBackground: Colors.teal.shade600,
              stubColor: const Color(0xFFE7EBF0),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BackgroundWrapper(child: UpiHistoryScreen()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Wallet chip shown in app bar to mimic the screenshot's balance pill
  Widget _WalletChip({
    required Color background,
    required Color textColor,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.qr_code_2_rounded, color: iconColor, size: 18),
          const SizedBox(width: 6),
          Text(
            '₹0.00',
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Ticket-style tile closely matching the reference UI
  Widget _buildTicketTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBackground,
    required Color stubColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Main row content
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.black26, size: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
