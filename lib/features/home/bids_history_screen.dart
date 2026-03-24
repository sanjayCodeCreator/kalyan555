// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:sm_project/controller/model/get_bids_history_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/bids_history_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class BidHistoryScreen extends ConsumerStatefulWidget {
  const BidHistoryScreen({super.key});

  @override
  ConsumerState<BidHistoryScreen> createState() => _BidHistoryScreenState();
}

class _BidHistoryScreenState extends ConsumerState<BidHistoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  String _currentQuery = '';
  bool _noDataDialogShown = false;

  @override
  void initState() {
    super.initState();
    // Build initial query with user_id if available
    ref
        .read(getParticularPlayerNotifierProvider.notifier)
        .getParticularPlayerModel()
        .then((value) {
      final userId = ref
              .read(getParticularPlayerNotifierProvider)
              .value
              ?.getParticularPlayerModel
              ?.data
              ?.sId ??
          '';
      _currentQuery = userId.isEmpty ? '' : '?user_id=$userId';
      ref
          .read(getbidsHistoryNotifierProvider.notifier)
          .bidsHistoryModel(_currentQuery);
    });

    _scrollController.addListener(_scrollListener);
    _controller = AnimationController(vsync: this);
  }

  void _scrollListener() {
    // Check if we're near the bottom of the list (200 pixels from the end)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Get the current state to check if we're already loading or if there's no more data
      final historyState = ref.read(getbidsHistoryNotifierProvider).value;

      // Only load more if we're not already loading and there's more data to load
      if (!(historyState?.isLoadingMore ?? false) &&
          (historyState?.hasMore ?? false)) {
        // Load more data when user is near the end of the list
        ref
            .read(getbidsHistoryNotifierProvider.notifier)
            .loadMore(_currentQuery);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const primaryGreen = Color(0xFF4CAF50);
    const lightGreen = Color(0xFF81C784);
    const backgroundColor = Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          "Bids History",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGreen, lightGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    60,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.all(10),
              //     decoration: BoxDecoration(
              //       color: whiteBackgroundColor,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: const Text(
              //       'Bids History',
              //       textAlign: TextAlign.center,
              //       style: TextStyle(
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //           color: Colors.black),
              //     )),

              Row(children: [
                Expanded(
                    child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(getbidsHistoryNotifierProvider.notifier)
                        .selectDate(context, true);
                  },
                  child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: primaryGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "From Date" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.day.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.month.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.year.toString() ?? ""}',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            )
                          ],
                        ),
                      )),
                )),
                const SizedBox(width: 12),
                Expanded(
                    child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(getbidsHistoryNotifierProvider.notifier)
                              .selectDate(context, false);
                        },
                        child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "To Date" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.day.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.month.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.year.toString() ?? ""}',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  )
                                ],
                              ),
                            ))))
              ]),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();

                  // Cache state reads
                  final historyState =
                      ref.watch(getbidsHistoryNotifierProvider).value;
                  final from = historyState?.fromDate;
                  final to = historyState?.toDate;

                  // Build user id from player provider
                  final userId = ref
                          .read(getParticularPlayerNotifierProvider)
                          .value
                          ?.getParticularPlayerModel
                          ?.data
                          ?.sId ??
                      '';

                  if (userId.isEmpty) {
                    toast(context: context, 'User not found');
                    return;
                  }

                  // Build query
                  String query = '?user_id=$userId';

                  if (from != null && to != null) {
                    String two(int v) => v.toString().padLeft(2, '0');

                    final fromStr =
                        '${from.year}-${two(from.month)}-${two(from.day)}';
                    final toStr = '${to.year}-${two(to.month)}-${two(to.day)}';

                    // tag is optional per new API, but if still required elsewhere, keep it as global
                    query += '&tag=main&from_date=$fromStr&to_date=$toStr';
                  } else if (from != null || to != null) {
                    toast(
                        context: context,
                        'Please select both From and To dates');
                    return;
                  }

                  // Update current query and reset scroll position
                  _currentQuery = query;

                  // Reset scroll position to top when performing a new search
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }

                  // Call API with new query
                  ref
                      .read(getbidsHistoryNotifierProvider.notifier)
                      .bidsHistoryModel(_currentQuery);

                  if (context.mounted) {
                    setState(() {
                      _noDataDialogShown = false;
                      _controller.reset();
                    });
                  }
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Search',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                final bets = (ref
                        .watch(getbidsHistoryNotifierProvider)
                        .value
                        ?.bidsHistoryModel
                        ?.data
                        ?.betList ??
                    <BetList>[]);

                final losingBets = bets
                    .where((e) => ((e.win ?? '').toLowerCase() != 'true'))
                    .toList();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Updated for new API response shape:
                    // Top-level: { status, data: { total, bet_list: [...] } }
                    // Access list safely from data.betList per new API

                    (losingBets.isEmpty)
                        ? Builder(
                            builder: (context) {
                              // Show one-time dialog matching the provided design when no data
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!_noDataDialogShown && mounted) {
                                  _noDataDialogShown = true;
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
                                                      fontWeight:
                                                          FontWeight.w700,
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
                                                        style:
                                                            GoogleFonts.poppins(
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
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 64,
                                                    height: 64,
                                                    decoration: BoxDecoration(
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
                              // Keep layout simple behind the dialog
                              return const SizedBox.shrink();
                            },
                          )
                        : Column(
                            children: [
                              ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: losingBets.length,
                                  itemBuilder: (context, index) {
                                    final data = losingBets[index];

                                    final dateTime = Jiffy.parse(
                                            data.createdAt?.split(".")[0] ?? '',
                                            isUtc: true)
                                        .toLocal();

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15.0),
                                      child: InkWell(
                                        onTap: () {
                                          // You can add functionality if needed
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 16, 16, 16),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 0, vertical: 0),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Colors.black12,
                                                    offset: Offset(0, 2),
                                                    blurRadius: 8,
                                                    spreadRadius: 0)
                                              ]),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Center(
                                                child: Text(
                                                  data.marketName ?? '',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: primaryGreen,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment: data
                                                                .gameMode !=
                                                            'double-digit' &&
                                                        data.gameMode !=
                                                            'full-sangam' &&
                                                        data.gameMode !=
                                                            'half-sangum'
                                                    ? MainAxisAlignment
                                                        .spaceBetween
                                                    : MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.gameMode !=
                                                                'double-digit' &&
                                                            data.gameMode !=
                                                                'full-sangam' &&
                                                            data.gameMode !=
                                                                'half-sangam'
                                                        ? "Session: ${data.session?.toUpperCase()}"
                                                        : '',
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Mode: ${(data.gameMode?.toUpperCase() == "DOUBLE-DIGIT" ? "JODI" : (data.gameMode ?? '')).toUpperCase()} ",
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if ((data.gameMode ?? '')
                                                          .trim()
                                                          .toUpperCase() ==
                                                      "DOUBLE-DIGIT")
                                                    Text(
                                                      'Open: ${data.openDigit?.toString() ?? '-'}\t\tClose: ${data.closeDigit?.toString() ?? '-'}',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: primaryGreen,
                                                      ),
                                                    )
                                                  else if ((data.gameMode
                                                                  ?.toLowerCase() ==
                                                              'single-digit' ||
                                                          data.gameMode
                                                                  ?.toLowerCase() ==
                                                              "even-odd-digit") &&
                                                      data.session == 'open' &&
                                                      data.openDigit != "-")
                                                    Text(
                                                        'Digit: ${data.openDigit?.toString() ?? '-'}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: primaryGreen,
                                                        ))
                                                  else if ((data
                                                                  .gameMode
                                                                  ?.toLowerCase() ==
                                                              'single-digit' ||
                                                          data.gameMode?.toLowerCase() ==
                                                              "even-odd-digit") &&
                                                      data.session == 'close' &&
                                                      data.closeDigit !=
                                                          "-") ...[
                                                    Text(
                                                      'Digit: ${data.closeDigit?.toString() ?? '-'}',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: primaryGreen,
                                                      ),
                                                    ),
                                                  ] else if (data
                                                              .gameMode !=
                                                          'half-sangam' &&
                                                      data
                                                              .gameMode !=
                                                          'full-sangam' &&
                                                      data.session == 'open' &&
                                                      data
                                                              .openPanna !=
                                                          "-") ...[
                                                    Text(
                                                        'Digit: ${data.openPanna?.toString() ?? '-'}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: primaryGreen,
                                                        )),
                                                  ] else if (data
                                                              .gameMode !=
                                                          'half-sangam' &&
                                                      data
                                                              .gameMode !=
                                                          'full-sangam' &&
                                                      data.session == 'close' &&
                                                      data
                                                              .closePanna !=
                                                          "-") ...[
                                                    Text(
                                                        'Digit: ${data.closePanna?.toString() ?? '-'}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: primaryGreen,
                                                        ))
                                                  ] else if (data.gameMode ==
                                                          'half-sangam' &&
                                                      data.openPanna !=
                                                          "-") ...[
                                                    Text(
                                                        'Open Panna: ${data.openPanna?.toString() ?? '-'}, \t\tClose Digit: ${data.closeDigit?.toString() ?? '-'}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: primaryGreen,
                                                        ))
                                                  ] else if (data.gameMode ==
                                                          'half-sangam' &&
                                                      data.closePanna !=
                                                          "-") ...[
                                                    Text(
                                                        'Close Panna: ${data.closePanna?.toString() ?? '-'}, \tOpen Digit: ${data.openDigit?.toString() ?? '-'}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: primaryGreen,
                                                        ))
                                                  ] else if (data.gameMode ==
                                                      'full-sangam') ...[
                                                    Text(
                                                        'Open Panna: ${data.openPanna?.toString() ?? '-'}, Close Pana: ${data.closePanna?.toString() ?? '-'}',
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: primaryGreen,
                                                        )),
                                                  ],
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                                    decoration: BoxDecoration(
                                                      color: primaryGreen
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Text(
                                                      (data.win?.toString() ??
                                                                      '')
                                                                  .toLowerCase() ==
                                                              'true'
                                                          ? data.betAmount
                                                                  ?.toString() ??
                                                              ''
                                                          : data.points
                                                                  ?.toString() ??
                                                              '',
                                                      style: GoogleFonts.poppins(
                                                        color: primaryGreen,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        dateTime.format(
                                                            pattern:
                                                                "dd-MMM-yyyy hh:mm a"),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                    ],
                                                  ),
                                                  Text(
                                                    "Points",
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              // Show loading indicator when loading more data
                              if (ref
                                      .watch(getbidsHistoryNotifierProvider)
                                      .value
                                      ?.isLoadingMore ??
                                  false)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                            color: primaryGreen),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Loading more bids...',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              // Show end of list indicator when there's no more data to load
                              if (!(ref
                                          .watch(getbidsHistoryNotifierProvider)
                                          .value
                                          ?.hasMore ??
                                      true) &&
                                  losingBets.isNotEmpty &&
                                  !(ref
                                          .watch(getbidsHistoryNotifierProvider)
                                          .value
                                          ?.isLoadingMore ??
                                      false))
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'You\'ve reached the end of the list',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Add a retry button in case loading failed
                                        TextButton.icon(
                                          onPressed: () {
                                            // Retry loading more data
                                            // We'll use the existing loadMore method which will handle the retry logic
                                            ref
                                                .read(
                                                    getbidsHistoryNotifierProvider
                                                        .notifier)
                                                .retryLoading(_currentQuery);
                                          },
                                          icon: Icon(Icons.refresh,
                                              color: primaryGreen),
                                          label: Text(
                                            'Retry',
                                            style: GoogleFonts.poppins(
                                              color: primaryGreen,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                primaryGreen.withOpacity(0.1),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ],
                );
              }),
            ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
