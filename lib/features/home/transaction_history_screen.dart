import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/transaction_history_notifier.dart';
import 'package:sm_project/controller/riverpod/withdrawal_notifier.dart';
import 'package:sm_project/features/home/upi_history_screen.dart';
import 'package:sm_project/utils/filecollection.dart';

class TransactionHistory extends HookConsumerWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref
          .read(getTransactionHistoryNotifierProvider.notifier)
          .getTransactionHistoryModel();
      ref
          .read(getWithdrawalNotifierProvider.notifier)
          .getSettingModelData(context);
      return;
    }, []);

    const primaryGreen = Color(0xFF4CAF50);
    const lightGreen = Color(0xFF81C784);
    const backgroundColor = Color(0xFFFAFAFA);

    return DefaultTabController(
      length: 1,
      child: Scaffold(
          backgroundColor: primaryGreen,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: context.canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    )
                  : null,
              title: Text(
                "Transaction History",
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              bottom: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                indicator: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white,
                      width: 3.0,
                    ),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3.0,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('UPI'),
                    ),
                  ),
                  // Tab(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 8.0),
                  //     child: Text('QR'),
                  //   ),
                  // ),
                ],
              )),
          body: Container(
            decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: const TabBarView(
              children: [
                UpiHistoryScreen(),
                // QrHistoryScreen(),
              ],
            ),
          )),
    );
  }
}
