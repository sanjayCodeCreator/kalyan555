import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/apiservices/api_service.dart';
import 'package:sm_project/controller/model/main_market_result_model.dart';
import 'package:sm_project/utils/filecollection.dart';

class ChartScreen extends ConsumerStatefulWidget {
  final String marketId;
  final String marketName;

  const ChartScreen({
    super.key,
    required this.marketId,
    required this.marketName,
  });

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  final ApiService _apiService = ApiService();
  GetMarketResultsModel? _marketResults;
  bool _isLoading = false;
  bool _isRefreshing = false;
  DateTime _selectedMonth = DateTime.now();

  // Colors matching the clean table look
  static const Color borderColor = Colors.black;
  static const Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _fetchMarketResults();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchMarketResults() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.getMainMarketResults(
        marketId: widget.marketId,
      );

      log("API Response: ${results?.toJson()}", name: "API_DEBUG");

      if (results != null && results.status == "success") {
        setState(() {
          _marketResults = results;
        });
      } else {
        toast(results?.message ?? "Failed to fetch market results");
      }
    } catch (e) {
      log("Error: $e", name: "API_DEBUG");
      toast("Error fetching market results");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshResults() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    await _fetchMarketResults();

    setState(() {
      _isRefreshing = false;
    });
  }

  List<DateTime> _generateDateRange() {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    List<DateTime> dates = [];
    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }
    return dates;
  }

  void _changeMonth(int direction) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + direction,
        1,
      );
    });
  }

  String _getMonthYearString() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  MarketResultModel? _getResultForDate(DateTime date) {
    if (_marketResults?.data == null) return null;

    final targetDate = DateTime(date.year, date.month, date.day);

    try {
      return _marketResults!.data!.firstWhere(
        (result) {
          if (result.from == null) return false;
          try {
            final apiDate = DateTime.parse(result.from!);
            final apiDateOnly =
                DateTime(apiDate.year, apiDate.month, apiDate.day);
            return targetDate.isAtSameMomentAs(apiDateOnly);
          } catch (e) {
            return false;
          }
        },
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.marketName.toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isLoading ? null : _refreshResults,
          ),
        ],
      ),
      body: _isLoading && _marketResults == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildMonthNavigator(),
                const SizedBox(height: 10),
                Expanded(child: _buildCalendarGrid()),
              ],
            ),
    );
  }

  Widget _buildMonthNavigator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
            color: Colors.black,
          ),
          Text(
            _getMonthYearString(),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
          left: BorderSide(color: borderColor, width: 1),
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
            .map((day) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: borderColor, width: 0.5),
                      ),
                    ),
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final dates = _generateDateRange();
    final firstDate = dates.first;
    final startWeekday = firstDate.weekday % 7; // 0 for Sunday

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildWeekdayHeader(),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio:
                  0.55, // Adjusted for taller cells to fit vertical stacks
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: dates.length + startWeekday,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                );
              }

              final dateIndex = index - startWeekday;
              if (dateIndex >= dates.length) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                );
              }

              final date = dates[dateIndex];
              final result = _getResultForDate(date);
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;

              return _buildTableCell(date, result, isToday);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableCell(
      DateTime date, MarketResultModel? result, bool isToday) {
    final hasData = result?.openDigit != null && result!.openDigit!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isToday ? Colors.yellow.withOpacity(0.1) : Colors.white,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Date header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Text(
              date.day.toString(),
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Market data
          Expanded(
            child: hasData
                ? _buildTableMarketData(result)
                : _buildTableMarketData(MarketResultModel(
                    openPanna: "***",
                    openDigit: "*",
                    closeDigit: "*",
                    closePanna: "***",
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildTableMarketData(MarketResultModel result) {
    // Helper to split panna into digits
    List<String> getPannaDigits(String? panna) {
      if (panna == null || panna.isEmpty) return ['*', '*', '*'];
      // Handle asterisks explicitly if they are passed as a string "***"
      if (panna.contains('*')) return ['*', '*', '*'];

      // Ensure we only take 3 digits max
      String cleanPanna = panna.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPanna.isEmpty) return ['*', '*', '*'];
      return cleanPanna.split('').take(3).toList();
    }

    final openPannaDigits = getPannaDigits(result.openPanna);
    final closePannaDigits = getPannaDigits(result.closePanna);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Open Panna Vertical
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: openPannaDigits
                .map((d) => Text(
                      d,
                      style: GoogleFonts.roboto(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ))
                .toList(),
          ),
          // Jodi
          Expanded(
            child: Text(
              "${result.openDigit ?? '*'}${result.closeDigit ?? '*'}",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ),
          // Close Panna Vertical
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: closePannaDigits
                .map((d) => Text(
                      d,
                      style: GoogleFonts.roboto(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
