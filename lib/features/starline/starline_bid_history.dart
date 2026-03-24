import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sm_project/controller/model/get_bids_history_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/bids_history_notifier.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/filecollection.dart';

class StarlineBidHistoryScreen extends ConsumerStatefulWidget {
  const StarlineBidHistoryScreen({super.key});

  @override
  ConsumerState<StarlineBidHistoryScreen> createState() =>
      _StarlineBidHistoryScreenState();
}

class _StarlineBidHistoryScreenState
    extends ConsumerState<StarlineBidHistoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  String _currentQuery = '';

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
      _currentQuery = userId.isEmpty ? '' : '?user_id=$userId&tag=starline';
      ref
          .read(getbidsHistoryNotifierProvider.notifier)
          .bidsHistoryModel(_currentQuery);
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
      appBar: AppBar(
        elevation: 3,
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: buttonForegroundColor),
        title: const Text(
          "Bid History",
          style: TextStyle(
            color: buttonForegroundColor,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
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
                          color: buttonColor,
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
                                    color: buttonForegroundColor))
                          ])),
                )),
                const SizedBox(width: 15),
                Expanded(
                    child: InkWell(
                        onTap: () {
                          ref
                              .read(getbidsHistoryNotifierProvider.notifier)
                              .selectDate(context, false);
                        },
                        child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: buttonColor,
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
                      ref.watch(getbidsHistoryNotifierProvider).value?.toDate ==
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
                          '?tag=starline&from=${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromDate}T00:00:00.000Z&to=${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toDate}T23:59:59.999Z');
                  if (context.mounted) {
                    setState(() {
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
                      color: Colors.white,
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
                          <BetList>[];
                      final filtered = list
                          .where((element) =>
                              element.win != "true" &&
                              (element.tag?.toLowerCase() == "starline"))
                          .toList();
                      return filtered.isEmpty;
                    })()
                        ? Column(
                            children: [
                              Lottie.asset(
                                'assets/no-data-found.json',
                                controller: _controller,
                                onLoaded: (composition) {
                                  _controller
                                    ..duration = composition.duration
                                    ..forward();
                                },
                              ),
                              const Text('No Data Found',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: (() {
                              final list = ref
                                      .watch(getbidsHistoryNotifierProvider)
                                      .value
                                      ?.bidsHistoryModel
                                      ?.data
                                      ?.betList ??
                                  <BetList>[];
                              return list
                                  .where((element) =>
                                      element.win != "true" &&
                                      (element.tag?.toLowerCase() ==
                                          "starline"))
                                  .length;
                            })(),
                            itemBuilder: (context, index) {
                              final data = (() {
                                final list = ref
                                        .watch(getbidsHistoryNotifierProvider)
                                        .value
                                        ?.bidsHistoryModel
                                        ?.data
                                        ?.betList ??
                                    <BetList>[];
                                final filtered = list
                                    .where((element) =>
                                        element.win != "true" &&
                                        (element.tag?.toLowerCase() ==
                                            "starline"))
                                    .toList();
                                return filtered[index];
                              })();

                              final dateTime =
                                  DateTime.parse(data.createdAt ?? '');
                              // Format the date

                              final formattedConvertDate =
                                  DateFormat('yyyy-MM-dd - kk:mm')
                                      .format(dateTime)
                                      .substring(0, 10);

                              final formattedDate =
                                  dateTime.toString().substring(10);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: Colors.white,
                                  elevation: 4,
                                  surfaceTintColor: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            data.marketName ?? '',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: darkBlue,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Row(
                                          mainAxisAlignment: data.gameMode !=
                                                      'double-digit' &&
                                                  data.gameMode !=
                                                      'full-sangam' &&
                                                  data.gameMode != 'half-sangam'
                                              ? MainAxisAlignment.spaceBetween
                                              : MainAxisAlignment.start,
                                          children: [
                                            Text(data.gameMode !=
                                                        'double-digit' &&
                                                    data.gameMode !=
                                                        'full-sangam' &&
                                                    data.gameMode !=
                                                        'half-sangam'
                                                ? "Session: ${data.session?.toUpperCase()}"
                                                : ''),
                                            Text(
                                                "Mode: ${(data.gameMode?.toUpperCase() == "DOUBLE-DIGIT" ? "JODI" : data.gameMode ?? '').toUpperCase()} "),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (data.gameMode
                                                    ?.trim()
                                                    .toUpperCase() ==
                                                "DOUBLE-DIGIT")
                                              Text(
                                                'Open: ${data.openDigit?.toString() ?? '-'}\t\tClose: ${data.closeDigit?.toString() ?? '-'}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: darkBlue,
                                                ),
                                              )
                                            else if (data.gameMode ==
                                                    'single-digit' &&
                                                data.session == 'open' &&
                                                data.openDigit != "-")
                                              Text(
                                                  'Digit: ${data.openDigit?.toString() ?? '-'}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w900,
                                                    color: darkBlue,
                                                  ))
                                            else if (data.gameMode ==
                                                    'single-digit' &&
                                                data.session == 'close' &&
                                                data.closeDigit != "-") ...[
                                              Text(
                                                'Digit: ${data.closeDigit?.toString() ?? '-'}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: darkBlue,
                                                ),
                                              ),
                                            ] else if (data.gameMode !=
                                                    'half-sangum' &&
                                                data.gameMode !=
                                                    'full-sangam' &&
                                                data.session == 'open' &&
                                                data.openPanna != "-") ...[
                                              Text(
                                                  'Digit: ${data.openPanna?.toString() ?? '-'}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: darkBlue)),
                                            ] else if (data.gameMode !=
                                                    'half-sangum' &&
                                                data.gameMode !=
                                                    'full-sangam' &&
                                                data.session == 'close' &&
                                                data.closePanna != "-") ...[
                                              Text(
                                                  'Digit: ${data.closePanna?.toString() ?? '-'}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: darkBlue))
                                            ] else if (data.gameMode ==
                                                    'half-sangum' &&
                                                data.openPanna != "-") ...[
                                              Text(
                                                  'Open Panna: ${data.openPanna?.toString() ?? '-'}, \t\tClose Digit: ${data.closeDigit?.toString() ?? '-'}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: darkBlue))
                                            ] else if (data.gameMode ==
                                                    'half-sangum' &&
                                                data.closePanna != "-") ...[
                                              Text(
                                                  'Close Panna: ${data.closePanna?.toString() ?? '-'}, \tOpen Digit: ${data.openDigit?.toString() ?? '-'}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: darkBlue))
                                            ] else if (data.gameMode ==
                                                'full-sangam') ...[
                                              Text(
                                                  'Open Panna: ${data.openPanna?.toString() ?? '-'}, Close Pana: ${data.closePanna?.toString() ?? '-'}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: darkBlue)),
                                            ],
                                            Text(
                                              data.win == "true"
                                                  ? data.betAmount
                                                          ?.toString() ??
                                                      ''
                                                  : data.points?.toString() ??
                                                      '',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  formattedConvertDate,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: textColor
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  // formattedDate,
                                                  convert24HrTo12Hr(
                                                      formattedDate),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: textColor
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Text(
                                              "Points",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: textColor.withOpacity(0.17),
                                          height: 20,
                                          thickness: 1,
                                          indent: 0,
                                          endIndent: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                  ],
                );
              }),
            ]),
      )),
    );
  }
}
