import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sm_project/roulette/roulette_api_service.dart';
import 'package:sm_project/roulette/roulette_bid_model.dart';
import 'package:sm_project/utils/filecollection.dart';

class RouletteBidHistoryScreen extends StatefulWidget {
  final String userId;

  const RouletteBidHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<RouletteBidHistoryScreen> createState() =>
      _RouletteBidHistoryScreenState();
}

class _RouletteBidHistoryScreenState extends State<RouletteBidHistoryScreen> {
  final RouletteApiService _apiService = RouletteApiService();
  List<RouletteBidModel> _bidHistory = [];
  bool _isLoading = true;

  // Date selection variables
  DateTime? _fromDate;
  DateTime? _toDate;
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _fetchBidHistory();
  }

  Future<void> _fetchBidHistory() async {
    try {
      String? fromString;
      String? toString;

      if (_fromDate != null) {
        final startOfDay =
            DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        fromString = startOfDay.toUtc().toIso8601String();
      }

      if (_toDate != null) {
        final endOfDay = DateTime(
            _toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59, 999);
        toString = endOfDay.toUtc().toIso8601String();
      }

      final bids = await _apiService.getBets(
        userId: widget.userId,
        win: null,
        from: fromString,
        to: toString,
      );

      setState(() {
        _bidHistory = bids;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching bid history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A256E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fromDate) {
      setState(() {
        _fromDate = picked;
        // If to date is before from date, clear it
        if (_toDate != null && _toDate!.isBefore(picked)) {
          _toDate = null;
        }
      });
      _refetchData();
    }
  }

  Future<void> _selectToDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A256E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _toDate) {
      setState(() {
        _toDate = picked;
      });
      _refetchData();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
    _refetchData();
  }

  void _refetchData() {
    setState(() {
      _isLoading = true;
    });
    _fetchBidHistory();
  }

  Widget _buildDateFilterSection() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6A256E),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Date Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A256E),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectFromDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fromDate != null
                              ? _dateFormatter.format(_fromDate!)
                              : 'From Date',
                          style: TextStyle(
                            color:
                                _fromDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: _selectToDate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _toDate != null
                              ? _dateFormatter.format(_toDate!)
                              : 'To Date',
                          style: TextStyle(
                            color: _toDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_fromDate != null || _toDate != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearDateFilter,
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear Filter'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6A256E),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bid History',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A256E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildDateFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD9BC4C),
                    ),
                  )
                : _bidHistory.isEmpty
                    ? const Center(
                        child: Text(
                          'No bid history found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchBidHistory,
                        color: const Color(0xFFD9BC4C),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _bidHistory.length,
                          itemBuilder: (context, index) {
                            final bid = _bidHistory[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Color(0xFF6A256E),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          bid.marketName ?? 'Unknown Market',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6A256E),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: bid.win == 'true'
                                                ? Colors.green.shade100
                                                : bid.win == 'false'
                                                    ? Colors.red.shade100
                                                    : Colors.orange.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: bid.win == 'true'
                                                  ? Colors.green
                                                  : bid.win == 'false'
                                                      ? Colors.red
                                                      : Colors.orange,
                                            ),
                                          ),
                                          child: Text(
                                            bid.win == 'true'
                                                ? 'Win'
                                                : bid.win == 'false'
                                                    ? 'Loss'
                                                    : 'Pending',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: bid.win == 'true'
                                                  ? Colors.green.shade800
                                                  : bid.win == 'false'
                                                      ? Colors.red.shade800
                                                      : Colors.orange.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Bid Digits',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                _buildDigitCircle(
                                                  _formatDigitDisplay(
                                                      bid.digit1,
                                                      bid.digit2,
                                                      bid.digit3,
                                                      0),
                                                ),
                                                const SizedBox(width: 4),
                                                _buildDigitCircle(
                                                  _formatDigitDisplay(
                                                      bid.digit1,
                                                      bid.digit2,
                                                      bid.digit3,
                                                      1),
                                                ),
                                                const SizedBox(width: 4),
                                                _buildDigitCircle(
                                                  _formatDigitDisplay(
                                                      bid.digit1,
                                                      bid.digit2,
                                                      bid.digit3,
                                                      2),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Points',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${bid.points ?? 0}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFFD9BC4C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Game Mode',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              bid.gameMode?.toUpperCase() ??
                                                  'N/A',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            const Text(
                                              'Date & Time',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              _formatDateTime(bid.createdAt),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (bid.result != null && bid.result != '-')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Result',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              bid.result ?? '',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitCircle(String digit) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6A256E),
        border: Border.all(
          color: const Color(0xFFD9BC4C),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Format digit display based on game mode (single, double, triple)
  String _formatDigitDisplay(
      String? digit1, String? digit2, String? digit3, int position) {
    // Handle null values
    digit1 = digit1 ?? '-';
    digit2 = digit2 ?? '-';
    digit3 = digit3 ?? '-';

    // Count non-dash digits to determine game mode
    int validDigitCount = 0;
    if (digit1 != '-') validDigitCount++;
    if (digit2 != '-') validDigitCount++;
    if (digit3 != '-') validDigitCount++;

    // Format based on game mode and position
    switch (validDigitCount) {
      case 1: // Single digit
        // For single digit, only the last position shows the value
        return position == 2
            ? (digit1 != '-' ? digit1 : (digit2 != '-' ? digit2 : digit3))
            : '-';

      case 2: // Double digit
        // For double digit, first position is dash, other two have values
        if (position == 0) {
          return '-';
        } else {
          // Find the two non-dash values
          List<String> values = [];
          if (digit1 != '-') values.add(digit1);
          if (digit2 != '-') values.add(digit2);
          if (digit3 != '-') values.add(digit3);

          return position - 1 < values.length ? values[position - 1] : '-';
        }

      case 3: // Triple digit
        // For triple digit, all positions show values
        switch (position) {
          case 0:
            return digit1;
          case 1:
            return digit2;
          case 2:
            return digit3;
          default:
            return '-';
        }

      default: // Invalid or empty
        return '-';
    }
  }
}
