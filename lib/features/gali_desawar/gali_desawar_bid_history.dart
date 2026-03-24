import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/bids_history_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/filecollection.dart';

class GaliDesawarBidHistoryScreen extends ConsumerStatefulWidget {
  final String tag;
  const GaliDesawarBidHistoryScreen({required this.tag, super.key});

  @override
  ConsumerState<GaliDesawarBidHistoryScreen> createState() =>
      _GaliDesawarBidHistoryScreenState();
}

class _GaliDesawarBidHistoryScreenState
    extends ConsumerState<GaliDesawarBidHistoryScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  // UI helpers (no logic changes)
  BoxDecoration _controlDecoration() {
    return BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: darkBlue.withOpacity(0.6), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _dateControl({
    required VoidCallback onTap,
    required String label,
    required DateTime? date,
  }) {
    final text = date == null
        ? label
        : '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _controlDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month, color: buttonForegroundColor),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: buttonForegroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({required VoidCallback onTap, required String title}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [darkBlue, darkBlue.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkBlue.withOpacity(0.8), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

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
      final currentQuery = userId.isEmpty
          ? '?tag=${widget.tag}'
          : '?user_id=$userId&tag=${widget.tag}';
      ref
          .read(getbidsHistoryNotifierProvider.notifier)
          .bidsHistoryModel(currentQuery);
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
    return BackgroundWrapper(
      child: Scaffold(
        appBar: AppBar(
          elevation: 3,
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: buttonForegroundColor),
          title: Text(
            "Bid History",
            style: GoogleFonts.poppins(
              color: buttonForegroundColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
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
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: _dateControl(
                      onTap: () {
                        ref
                            .read(getbidsHistoryNotifierProvider.notifier)
                            .selectDate(context, true);
                      },
                      label: 'From Date',
                      date: ref
                          .watch(getbidsHistoryNotifierProvider)
                          .value
                          ?.fromDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateControl(
                      onTap: () {
                        ref
                            .read(getbidsHistoryNotifierProvider.notifier)
                            .selectDate(context, false);
                      },
                      label: 'To Date',
                      date: ref
                          .watch(getbidsHistoryNotifierProvider)
                          .value
                          ?.toDate,
                    ),
                  ),
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
                            '?tag=${widget.tag}&from=${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromDate}T00:00:00.000Z&to=${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toDate}T23:59:59.999Z');
                    if (context.mounted) {
                      setState(() {
                        _controller.reset();
                      });
                    }
                  },
                  child: _primaryButton(
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
                                '?tag=${widget.tag}&from=${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.fromDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.fromDate == null ? "" : fromDate}T00:00:00.000Z&to=${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : ref.watch(getbidsHistoryNotifierProvider).value?.toDate?.year.toString()}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toMonth}-${ref.watch(getbidsHistoryNotifierProvider).value?.toDate == null ? "" : toDate}T23:59:59.999Z');
                        if (context.mounted) {
                          setState(() {
                            _controller.reset();
                          });
                        }
                      },
                      title: 'Search'),
                ),
                const SizedBox(height: 20),
                Consumer(builder: (context, ref, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ref
                                  .watch(getbidsHistoryNotifierProvider)
                                  .value
                                  ?.bidsHistoryModel
                                  ?.data
                                  ?.betList
                                  ?.where((element) =>
                                      element.win != "true" &&
                                      (element.tag?.toLowerCase() ==
                                          widget.tag))
                                  .isEmpty ??
                              true
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
                                Text(
                                  'No Data Found',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: ref
                                      .watch(getbidsHistoryNotifierProvider)
                                      .value
                                      ?.bidsHistoryModel
                                      ?.data
                                      ?.betList
                                      ?.where((element) =>
                                          element.win != "true" &&
                                          (element.tag?.toLowerCase() ==
                                              widget.tag))
                                      .length ??
                                  0,
                              itemBuilder: (context, index) {
                                final data = ref
                                    .watch(getbidsHistoryNotifierProvider)
                                    .value
                                    ?.bidsHistoryModel
                                    ?.data
                                    ?.betList
                                    ?.where((element) =>
                                        element.win != "true" &&
                                        (element.tag?.toLowerCase() ==
                                            widget.tag))
                                    .toList()[index];

                                final dateTime =
                                    DateTime.parse(data?.createdAt ?? '');
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide()),
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
                                              data?.marketName ?? '',
                                              style: GoogleFonts.poppins(
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
                                          const SizedBox(height: 3),
                                          if (data?.closeDigit.toString() ==
                                              "-") ...{
                                            Text(
                                              "Left: ${data?.openDigit.toString() ?? ""}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          } else if (data?.openDigit
                                                  .toString() ==
                                              "-") ...{
                                            Text(
                                              "Right: ${data?.closeDigit.toString() ?? ""}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          } else ...{
                                            Text(
                                              "Jodi: ${data?.openDigit.toString() ?? ""}${data?.closeDigit.toString() ?? ""}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          },
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
                                              Column(
                                                children: [
                                                  Text(
                                                    data?.points.toString() ??
                                                        "",
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "Points",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
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
      ),
    );
  }
}
