import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sm_project/controller/model/transaction_history_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class UpiHistoryScreen extends ConsumerStatefulWidget {
  const UpiHistoryScreen({super.key});

  @override
  ConsumerState<UpiHistoryScreen> createState() => _UpiHistoryScreenState();
}

class _UpiHistoryScreenState extends ConsumerState<UpiHistoryScreen> {
  final apiService = ApiService();
  List<Data> transactions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true; // whether more pages are available
  int skip = 0; // page index
  final int count = 10; // page size
  final ScrollController _scrollController = ScrollController();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  bool _noDataDialogShown = false;

  @override
  void initState() {
    super.initState();
    _fetchUpiTransactions(initial: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || isLoadingMore || isLoading || !hasMore)
      return;
    const threshold = 200.0; // pixels from bottom
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        threshold) {
      _fetchUpiTransactions();
    }
  }

  Future<void> _fetchUpiTransactions({bool initial = false}) async {
    if (initial) {
      setState(() {
        isLoading = true;
        skip = 0;
        hasMore = true;
        transactions.clear();
        _noDataDialogShown = false;
      });
    } else {
      if (!hasMore) return;
      setState(() {
        isLoadingMore = true;
      });
    }

    try {
      if (initial) EasyLoading.show(status: 'Loading...');
      await ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();

      final response = await apiService.getUpiTransactionHistory(
        skip: skip,
        count: count,
        userId: ref
                .watch(getParticularPlayerNotifierProvider)
                .value
                ?.getParticularPlayerModel
                ?.data
                ?.sId ??
            "",
        transferType: "upi",
      );

      if (response?.status == "success") {
        final fetched = response?.data ?? [];
        if (context.mounted) {
          setState(() {
            if (initial) {
              transactions = fetched;
            } else {
              transactions.addAll(fetched);
            }
            // If fewer than count items returned, no more pages
            if (fetched.length < count) {
              hasMore = false;
            } else {
              skip += 1; // next page index
            }
          });
        }
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: 'getUpiTransactionHistory');
    } finally {
      if (initial) {
        EasyLoading.dismiss();
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: context.canPop()
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              title: Text(
                'UPI History',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : transactions.isEmpty
                      ? Builder(builder: (context) {
                          // Show a one-time "No Account History Found" dialog matching bids_history_screen design
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!_noDataDialogShown && mounted) {
                              _noDataDialogShown = true;
                              const primaryGreen = Color(0xFF4CAF50);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(
                                        horizontal: 40),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(top: 40),
                                          padding: const EdgeInsets.fromLTRB(
                                              24, 32, 24, 24),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: primaryGreen,
                                              width: 3,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const SizedBox(height: 8),
                                              Text(
                                                'No Account History\nFound',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              SizedBox(
                                                width: 140,
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                  },
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    backgroundColor:
                                                        primaryGreen,
                                                    shape:
                                                        const StadiumBorder(),
                                                    elevation: 0,
                                                  ),
                                                  child: Text(
                                                    'OK',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          top: -8,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 64,
                                                height: 64,
                                                decoration: const BoxDecoration(
                                                  color: primaryGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.info,
                                                  color: Colors.white,
                                                  size: 34,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          });
                          return const SizedBox.shrink();
                        })
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              transactions.length + (isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == transactions.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            final transaction = transactions[index];
                            final bool isCredit =
                                (transaction.type ?? '').toLowerCase() ==
                                    'credit';

                            final dateTime = Jiffy.parse(
                                    transaction.createdAt?.split(".")[0] ?? '',
                                    isUtc: true)
                                .toLocal();

                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isCredit
                                        ? primaryGreen.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isCredit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isCredit ? primaryGreen : Colors.red,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  isCredit ? 'Deposit' : 'Withdrawal',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amount: ₹${transaction.amount ?? 0}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${_toTitleCase(transaction.status ?? 'Pending')}',
                                      style: GoogleFonts.poppins(
                                        color: getStatusColor(
                                            transaction.status ?? ''),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (transaction.createdAt != null)
                                      Text(
                                        dateTime.format(
                                            pattern: "dd-MMM-yyyy hh:mm a"),
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  isCredit
                                      ? '+₹${transaction.amount ?? 0}'
                                      : '-₹${transaction.amount ?? 0}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: isCredit ? primaryGreen : Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _toTitleCase(String value) {
    if (value.trim().isEmpty) return value;
    return value
        .split(RegExp(r'[ _-]+'))
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
