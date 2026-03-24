import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sm_project/controller/model/transaction_history_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/utils/filecollection.dart';

class QrHistoryScreen extends StatefulWidget {
  const QrHistoryScreen({super.key});

  @override
  State<QrHistoryScreen> createState() => _QrHistoryScreenState();
}

class _QrHistoryScreenState extends State<QrHistoryScreen> {
  final apiService = ApiService();
  List<Data> transactions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true;
  int skip = 0; // page index
  final int count = 10; // page size
  final ScrollController _scrollController = ScrollController();
  bool _noDataDialogShown = false;

  // Date selection
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _fetchQrTransactions(initial: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Date pickers removed (unused in current UI)

  void _onScroll() {
    if (!_scrollController.hasClients || isLoadingMore || isLoading || !hasMore)
      return;
    const threshold = 200.0;
    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <=
        threshold) {
      _fetchQrTransactions();
    }
  }

  Future<void> _fetchQrTransactions({bool initial = false}) async {
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

      final DateTime fromDateStart =
          DateTime(fromDate.year, fromDate.month, fromDate.day);
      final DateTime toDateEnd =
          DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59, 999);

      final response = await apiService.getQrTransactionHistory(
        fromDate: fromDateStart,
        toDate: toDateEnd,
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
            skip += 1; // next page index
          }
        });
      } else {
        setState(() {
          hasMore = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while fetching transactions")),
      );
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
    return Scaffold(
      appBar: context.canPop()
          ? AppBar(
              backgroundColor: Colors.black,
              title: const Text('QR History'),
            )
          : null,
      backgroundColor: darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? Builder(builder: (context) {
                          // Mirror bids_history_screen one-time dialog
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

                            final dateTime = Jiffy.parse(
                                    transaction.createdAt?.split(".")[0] ?? '',
                                    isUtc: true)
                                .toLocal();

                            return Card(
                              color: Colors.white,
                              surfaceTintColor: Colors.white,
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
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                                title: const Text(
                                  'QR Deposit',
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
                                        color: getStatusColor(
                                            transaction.status ?? ''),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    if (transaction.note != null &&
                                        transaction.note!.isNotEmpty)
                                      Text(
                                        'Note: ${transaction.note}',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    if (transaction.createdAt != null)
                                      Text(
                                        dateTime.format(
                                            pattern: "dd-MMM-yyyy hh:mm a"),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  '+₹${transaction.amount ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
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
