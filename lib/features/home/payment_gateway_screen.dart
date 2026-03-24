import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sm_project/controller/model/transaction_history_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class PaymentGatewayHistoryScreen extends ConsumerStatefulWidget {
  const PaymentGatewayHistoryScreen({super.key});

  @override
  ConsumerState<PaymentGatewayHistoryScreen> createState() =>
      _PaymentGatewayHistoryScreenState();
}

class _PaymentGatewayHistoryScreenState
    extends ConsumerState<PaymentGatewayHistoryScreen> {
  final apiService = ApiService();
  List<Data> transactions = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMore = true; // whether more pages are available
  int skip = 0; // page index
  final int count = 10; // page size
  final ScrollController _scrollController = ScrollController();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

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
          transferType: "provider");

      if (response?.status == "success") {
        final fetched = response?.data ?? [];
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
    return Scaffold(
      appBar: context.canPop()
          ? AppBar(
              backgroundColor: Colors.black,
              title: const Text('Payment Gateway History'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
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
                            const bool isCredit = true;

                            final dateTime = Jiffy.parse(
                                    transaction.createdAt?.split(".")[0] ?? '',
                                    isUtc: true)
                                .toLocal();

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
                                    color: isCredit
                                        ? Colors.green.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    isCredit
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isCredit ? Colors.green : Colors.red,
                                    size: 30,
                                  ),
                                ),
                                title: const Text(
                                  isCredit ? 'Deposit' : 'Withdrawal',
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
                                  isCredit
                                      ? '+₹${transaction.amount ?? 0}'
                                      : '-₹${transaction.amount ?? 0}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isCredit ? Colors.green : Colors.red,
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
