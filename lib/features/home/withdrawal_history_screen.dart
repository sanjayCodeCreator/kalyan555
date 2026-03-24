import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sm_project/controller/model/transaction_history_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/utils/filecollection.dart';

class WithdrawalHistoryScreen extends StatefulWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  State<WithdrawalHistoryScreen> createState() =>
      _WithdrawalHistoryScreenState();
}

class _WithdrawalHistoryScreenState extends State<WithdrawalHistoryScreen> {
  final apiService = ApiService();
  List<Data> transactions = [];
  bool isLoading = true; // initial page loading
  bool isLoadingMore = false; // while fetching next page
  bool hasMore = true; // whether more pages exist
  int skip = 0; // page index (0-based)
  final int count = 10; // page size
  final ScrollController _scrollController = ScrollController();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  bool _noDataDialogShown = false;

  @override
  void initState() {
    super.initState();
    _fetchWithdrawalTransactions(initial: true);
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
    const threshold = 200.0; // px from bottom
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        threshold) {
      _fetchWithdrawalTransactions();
    }
  }

  Future<void> _fetchWithdrawalTransactions({bool initial = false}) async {
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
      final response = await apiService.getWithdrawalTransactionHistory(
        skip: skip,
        count: count,
      );

      if (response?.status == "success") {
        final fetched = response?.data ?? [];
        setState(() {
          if (initial) {
            transactions = fetched;
          } else {
            transactions.addAll(fetched);
          }
          if (fetched.length < count) {
            hasMore = false;
          } else {
            skip += 1;
          }
        });
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("An error occurred while fetching transactions")),
        );
      }
    } finally {
      if (initial) {
        EasyLoading.dismiss();
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingMore = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Withdrawal History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? Builder(builder: (context) {
                          // Mirror one-time dialog from bids_history_screen
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
                                    insetPadding:
                                        const EdgeInsets.symmetric(horizontal: 40),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 40),
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
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: primaryGreen,
                                                    shape: const StadiumBorder(),
                                                    elevation: 0,
                                                  ),
                                                  child: Text(
                                                    'OK',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
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
                            final status =
                                transaction.status?.toLowerCase() ?? '';
                            final dateTime = Jiffy.parse(
                              transaction.createdAt?.split(".")[0] ?? '',
                              isUtc: true,
                            ).toLocal();

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_upward,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                                title: const Text(
                                  'Withdrawal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      'Amount: ₹${transaction.amount ?? 0}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Status: ${_toTitleCase(transaction.status ?? 'Pending')}',
                                      style: TextStyle(
                                        color: getStatusColor(status),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    if (transaction.createdAt != null)
                                      Text(
                                        dateTime.format(
                                            pattern: "dd MMM yyyy hh:mm a"),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  '-₹${transaction.amount ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
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

  String formatDate(String dateString) {
    final dateTime = DateTime.parse(dateString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _toTitleCase(String value) {
    if (value.trim().isEmpty) return value;
    return value
        .split(RegExp(r'[ _-]+'))
        .map((w) =>
            w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}
