// ignore_for_file: unrelated_type_equality_checks

import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/bids_history_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class BidWinHistoryScreen extends ConsumerStatefulWidget {
  const BidWinHistoryScreen({super.key});

  @override
  ConsumerState<BidWinHistoryScreen> createState() =>
      _BidWinHistoryScreenState();
}

class _BidWinHistoryScreenState extends ConsumerState<BidWinHistoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _noDataDialogShown = false;

  @override
  void initState() {
    super.initState();
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
      final initialQuery = userId.isEmpty ? '' : '?user_id=$userId&win=true';
      ref
          .read(getbidsHistoryNotifierProvider.notifier)
          .bidsHistoryModel(initialQuery);
    });
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: appColor,
          leading: context.canPop()
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 13, 0, 0),
                  child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: whiteBackgroundColor, width: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                                padding: EdgeInsets.fromLTRB(12.0, 10, 7, 10),
                                child: Icon(Icons.arrow_back_ios,
                                    size: 15, color: whiteBackgroundColor)))
                      ])),
                )
              : null,
          title: const Text(
            "Bids Win History",
            style: TextStyle(color: whiteBackgroundColor, fontSize: 18),
          ),
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          ref
                              .read(getbidsHistoryNotifierProvider.notifier)
                              .selectDate(context, true);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: darkBlue,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: buttonForegroundColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "From Date" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.day.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.month.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.year.toString() ?? ""}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: buttonForegroundColor),
                              )
                            ],
                          ),
                        ),
                      )),
                      const SizedBox(width: 15),
                      Expanded(
                          child: InkWell(
                              onTap: () {
                                ref
                                    .read(
                                        getbidsHistoryNotifierProvider.notifier)
                                    .selectDate(context, false);
                              },
                              child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: darkBlue,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.calendar_month,
                                          color: buttonForegroundColor,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                            '${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "To Date" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.day.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.month.toString() ?? ""} ${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.year.toString() ?? ""}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: buttonForegroundColor))
                                      ]))))
                    ]),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        if (ref
                                    .watch(getbidsHistoryNotifierProvider)
                                    .value
                                    ?.fromDate ==
                                null ||
                            ref
                                    .watch(getbidsHistoryNotifierProvider)
                                    .value
                                    ?.toDate ==
                                null) {
                          toast(context: context, 'Please select date');
                          return;
                        }

                        final String? fromDate = ref
                                    .watch(getbidsHistoryNotifierProvider)
                                    .value
                                    ?.fromDate
                                    ?.day
                                    .toString()
                                    .length ==
                                1
                            ? '0${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.day.toString()}'
                            : ref
                                .watch(getbidsHistoryNotifierProvider)
                                .value
                                ?.fromDate
                                ?.day
                                .toString();

                        final String? toDate = ref
                                    .watch(getbidsHistoryNotifierProvider)
                                    .value
                                    ?.toDate
                                    ?.day
                                    .toString()
                                    .length ==
                                1
                            ? '0${ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.day.toString()}'
                            : ref
                                .watch(getbidsHistoryNotifierProvider)
                                .value
                                ?.toDate
                                ?.day
                                .toString();

                        // Month

                        final String? fromMonth = ref
                                    .watch(getbidsHistoryNotifierProvider)
                                    .value
                                    ?.fromDate
                                    ?.month
                                    .toString()
                                    .length ==
                                1
                            ? '0${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.month.toString()}'
                            : ref
                                .watch(getbidsHistoryNotifierProvider)
                                .value
                                ?.fromDate
                                ?.month
                                .toString();

                        final String? toMonth = ref
                                    .watch(getbidsHistoryNotifierProvider)
                                    .value
                                    ?.toDate
                                    ?.month
                                    .toString()
                                    .length ==
                                1
                            ? '0${ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.month.toString()}'
                            : ref
                                .watch(getbidsHistoryNotifierProvider)
                                .value
                                ?.toDate
                                ?.month
                                .toString();

                        ref
                            .read(getbidsHistoryNotifierProvider.notifier)
                            .bidsHistoryModel(
                                '?tag=main&from_date=${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromDate}&to_date=${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toDate}');
                        if (context.mounted) {
                          setState(() {
                            _noDataDialogShown = false;
                            _controller.reset();
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text(
                          'Search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: whiteBackgroundColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Consumer(builder: (context, ref, child) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            (() {
                              final list = ref
                                      .watch(getbidsHistoryNotifierProvider)
                                      .value
                                      ?.bidsHistoryModel
                                      ?.data
                                      ?.betList ??
                                  const [];
                              return list
                                  .where((e) =>
                                      ((e.win ?? '').toLowerCase() == 'true'))
                                  .isEmpty;
                            })()
                                ? Builder(builder: (context) {
                                    // Show a one-time dialog similar to bids_history_screen when no data is available
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      if (!_noDataDialogShown && mounted) {
                                        _noDataDialogShown = true;
                                        const primaryGreen = Color(0xFF4CAF50);
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (ctx) {
                                            return Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              insetPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 40),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                alignment: Alignment.topCenter,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 40),
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        24, 32, 24, 24),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                        color: primaryGreen,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'No Account History\nFound',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors
                                                                .black87,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 20),
                                                        SizedBox(
                                                          width: 140,
                                                          height: 48,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop();
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
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
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
                                                                .withOpacity(
                                                                    0.1),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Center(
                                                        child: Container(
                                                          width: 64,
                                                          height: 64,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color:
                                                                primaryGreen,
                                                            shape:
                                                                BoxShape.circle,
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: (() {
                                      final list = ref
                                              .watch(
                                                  getbidsHistoryNotifierProvider)
                                              .value
                                              ?.bidsHistoryModel
                                              ?.data
                                              ?.betList ??
                                          const [];
                                      return list
                                          .where((e) =>
                                              ((e.win ?? '').toLowerCase() ==
                                                  'true'))
                                          .length;
                                    })(),
                                    itemBuilder: (context, index) {
                                      final data = (() {
                                        final list = ref
                                                .watch(
                                                    getbidsHistoryNotifierProvider)
                                                .value
                                                ?.bidsHistoryModel
                                                ?.data
                                                ?.betList ??
                                            const [];
                                        final filtered = list
                                            .where((e) =>
                                                ((e.win ?? '').toLowerCase() ==
                                                    'true'))
                                            .toList();
                                        return filtered[index];
                                      })();

                                      final dateTime = Jiffy.parse(
                                              data.createdAt?.split(".")[0] ??
                                                  '',
                                              isUtc: true)
                                          .toLocal();

                                      return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: Card(
                                              margin: EdgeInsets.zero,
                                              color: Colors.white,
                                              elevation: 4,
                                              surfaceTintColor: Colors.white,
                                              child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Center(
                                                          child: Text(
                                                            data.marketName ??
                                                                '',
                                                            style:
                                                                 TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: darkBlue,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 6,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: data
                                                                          .gameMode !=
                                                                      'double-digit' &&
                                                                  data.gameMode !=
                                                                      'full-sangam' &&
                                                                  data.gameMode !=
                                                                      'half-sangam'
                                                              ? MainAxisAlignment
                                                                  .spaceBetween
                                                              : MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(data
                                                                            .gameMode !=
                                                                        'double-digit' &&
                                                                    data.gameMode !=
                                                                        'full-sangam' &&
                                                                    data.gameMode !=
                                                                        'half-sangum'
                                                                ? "Session: ${data.session?.toUpperCase()}"
                                                                : ''),
                                                            Text(
                                                                "Mode: ${(data.gameMode?.toUpperCase() == "DOUBLE-DIGIT" ? "JODI" : data.gameMode ?? '').toUpperCase()} "),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              if (data.gameMode
                                                                      ?.trim()
                                                                      .toUpperCase() ==
                                                                  "DOUBLE-DIGIT")
                                                                Text(
                                                                  'Open: ${data.openDigit?.toString() ?? '-'}\t\tClose: ${data.closeDigit?.toString() ?? '-'}',
                                                                  style:
                                                                       TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    color:
                                                                        darkBlue,
                                                                  ),
                                                                )
                                                              else if ((data.gameMode ==
                                                                          'single-digit' ||
                                                                      data.gameMode ==
                                                                          "odd-even") &&
                                                                  data.session ==
                                                                      'open' &&
                                                                  data.openDigit !=
                                                                      "-")
                                                                Text(
                                                                    'Digit: ${data.openDigit?.toString() ?? '-'}',
                                                                    style:
                                                                         TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      color:
                                                                          darkBlue,
                                                                    ))
                                                              else if ((data
                                                                              .gameMode ==
                                                                          'single-digit' ||
                                                                      data.gameMode ==
                                                                          "odd-even") &&
                                                                  data.session ==
                                                                      'close' &&
                                                                  data.closeDigit !=
                                                                      "-") ...[
                                                                Text(
                                                                  'Digit: ${data.closeDigit?.toString() ?? '-'}',
                                                                  style:
                                                                       TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    color:
                                                                        darkBlue,
                                                                  ),
                                                                ),
                                                              ] else if (data
                                                                          .gameMode !=
                                                                      'half-sangum' &&
                                                                  data.gameMode !=
                                                                      'full-sangam' &&
                                                                  data.session ==
                                                                      'open' &&
                                                                  data.openPanna !=
                                                                      "-") ...[
                                                                Text(
                                                                    'Digit: ${data.openPanna?.toString() ?? '-'}',
                                                                    style:  TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        color:
                                                                            darkBlue)),
                                                              ] else if (data
                                                                          .gameMode !=
                                                                      'half-sangum' &&
                                                                  data.gameMode !=
                                                                      'full-sangam' &&
                                                                  data.session ==
                                                                      'close' &&
                                                                  data.closePanna !=
                                                                      "-") ...[
                                                                Text(
                                                                    'Digit: ${data.closePanna?.toString() ?? '-'}',
                                                                    style:  TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        color:
                                                                            darkBlue))
                                                              ] else if (data
                                                                          .gameMode ==
                                                                      'half-sangum' &&
                                                                  data.openPanna !=
                                                                      "-") ...[
                                                                Text(
                                                                    'Open Panna: ${data.openPanna?.toString() ?? '-'}, \t\tClose Digit: ${data.closeDigit?.toString() ?? '-'}',
                                                                    style:  TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        color:
                                                                            darkBlue))
                                                              ] else if (data
                                                                          .gameMode ==
                                                                      'half-sangum' &&
                                                                  data.closePanna !=
                                                                      "-") ...[
                                                                Text(
                                                                    'Close Panna: ${data.closePanna?.toString() ?? '-'}, \tOpen Digit: ${data.openDigit?.toString() ?? '-'}',
                                                                    style:  TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        color:
                                                                            darkBlue))
                                                              ] else if (data
                                                                      .gameMode ==
                                                                  'full-sangam') ...[
                                                                Text(
                                                                    'Open Panna: ${data.openPanna?.toString() ?? '-'}, Close Pana: ${data.closePanna?.toString() ?? '-'}',
                                                                    style:  TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w900,
                                                                        color:
                                                                            darkBlue)),
                                                              ],
                                                              Text(
                                                                  data.win ==
                                                                          "true"
                                                                      ? '+${data.winningAmount?.toString() ?? ''}'
                                                                      : '-${data.points?.toString() ?? ''}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: data.win ==
                                                                            "true"
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                  ))
                                                            ]),
                                                        const SizedBox(
                                                            height: 3),
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
                                                                          "dd MMM yyyy hh:mm a"),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    color: textColor
                                                                        .withOpacity(
                                                                            0.7),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              data.win == "true"
                                                                  ? 'Succeed'
                                                                  : 'Failed',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: data.win ==
                                                                        "true"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Divider(
                                                            color: textColor
                                                                .withOpacity(
                                                                    0.17),
                                                            height: 20,
                                                            thickness: 1,
                                                            indent: 0,
                                                            endIndent: 0)
                                                      ]))));
                                    })
                          ]);
                    })
                  ]))),
    );
  }
}
