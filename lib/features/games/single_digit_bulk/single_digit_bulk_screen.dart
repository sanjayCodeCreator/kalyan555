import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/games/single_digit_bulk/single_digit_bulk_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

class SingleDigitBulkScreen extends ConsumerStatefulWidget {
  final String id;
  final String tag;
  final String name;
  const SingleDigitBulkScreen({
    required this.id,
    required this.tag,
    required this.name,
    super.key,
  });

  @override
  ConsumerState<SingleDigitBulkScreen> createState() =>
      _SingleDigitBulkScreenState();
}

class _SingleDigitBulkScreenState extends ConsumerState<SingleDigitBulkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ApiService().getParticularUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: lightGreyColor,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        backgroundColor: lightGreyColor,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                HapticFeedback.mediumImpact();
                if (await isStopGameExecution(
                  context: context,
                  ref: ref,
                  marketId: widget.id,
                  gameName: "Single Digit Bulk",
                )) {
                  return;
                }
                if (context.mounted) {
                  ref
                      .read(singleDigitBulkNotifierProvider.notifier)
                      .onSubmitConfirm(
                        context,
                        widget.tag,
                        widget.id,
                      );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'SUBMIT',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: darkBlue,
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextMarqueeWidget(
                              child: Text(
                                "${widget.name}, Single Digit Bulk",
                                style: GoogleFonts.rubik(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Consumer(builder: (context, ref, _) {
                            final refWatch =
                                ref.watch(getParticularPlayerNotifierProvider);
                            return InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  context.pushNamed(RouteNames.deposit);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF0F8FF),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: darkBlue.withOpacity(0.3))),
                                  child: Row(children: [
                                    Image.asset(
                                      walletLogo,
                                      height: 18,
                                      width: 18,
                                      color: darkBlue,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                        refWatch.value?.getParticularPlayerModel
                                                ?.data?.wallet
                                                ?.toString() ??
                                            "",
                                        style: GoogleFonts.rubik(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: darkBlue,
                                        ))
                                  ]),
                                ));
                          }),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    OpenCloseComponent(
                      marketId: widget.id,
                    ),
                    const SizedBox(height: 6),
                    // Points entry field with improved styling
                    Consumer(
                      builder: (context, ref, _) {
                        final refWatch =
                            ref.watch(singleDigitBulkNotifierProvider).value;
                        final refRead = ref.read(
                          singleDigitBulkNotifierProvider.notifier,
                        );
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Points",
                                style: GoogleFonts.rubik(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: TextFormField(
                                  enableInteractiveSelection: false,
                                  controller: refWatch?.enteredPoints,
                                  focusNode: FocusNode(),
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.rubik(
                                    decoration: TextDecoration.none,
                                    fontSize: 13,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(color: darkBlue),
                                    ),
                                    hintText: "Enter Points",
                                    hintStyle: GoogleFonts.rubik(
                                      color: Colors.grey.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      refRead.updateEnteredPoints(value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Number grid with improved styling
                    Text(
                      "Select Numbers",
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Consumer(
                      builder: (context, ref, child) {
                        final refWatch = ref.watch(
                          singleDigitBulkNotifierProvider,
                        );
                        return Center(
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 6.0,
                              crossAxisSpacing: 6,
                              childAspectRatio: 1.0,
                            ),
                            itemCount:
                                refWatch.value?.singleDigitNewModel.length ?? 0,
                            itemBuilder: (context, index) {
                              final digit =
                                  refWatch.value?.singleDigitNewModel[index];
                              return chooseNumber(context, "${digit?.points}");
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Selected numbers table with improved styling
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: darkBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Digit",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Points",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Type",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Delete",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // List of numbers and points
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final refWatch = ref.watch(
                                    singleDigitBulkNotifierProvider,
                                  );
                                  final refRead = ref.read(
                                    singleDigitBulkNotifierProvider.notifier,
                                  );

                                  if (refWatch
                                          .value?.selectedNumberList.isEmpty ??
                                      true) {
                                    return Center(
                                      child: Text(
                                        "No numbers selected yet",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.rubik(
                                          fontSize: 11,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: refWatch
                                            .value?.selectedNumberList.length ??
                                        0,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final item = refWatch
                                          .value?.selectedNumberList[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Card(
                                          margin: EdgeInsets.zero,
                                          color: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            side: BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.15)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          6, 3, 6, 3),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF5F5F5),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.2)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                  child: Text(
                                                    item?.points ?? '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          6, 3, 6, 3),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF5F5F5),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.2)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                  child: Text(
                                                    item?.value ?? '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          6, 3, 6, 3),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF5F5F5),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.2)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
                                                  ),
                                                  child: Text(
                                                    item?.session
                                                            ?.toUpperCase() ??
                                                        '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    refRead.removePoints(
                                                      context,
                                                      item?.points ?? '',
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.08),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.red
                                                              .withOpacity(
                                                                  0.2)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7),
                                                    ),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Summary section similar to single_digit_new
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFFC000)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Game Summary',
                                    style: GoogleFonts.rubik(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final refWatch = ref.watch(
                                          singleDigitBulkNotifierProvider);
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _summaryItem(
                                            title: 'Numbers',
                                            value: refWatch
                                                    .value?.totalSelectedNumber
                                                    .toString() ??
                                                '0',
                                            icon: Icons.format_list_numbered,
                                          ),
                                          _summaryItem(
                                            title: 'Points',
                                            value: refWatch.value?.totalPoints
                                                    .toString() ??
                                                '0',
                                            icon: Icons.payments_outlined,
                                          ),
                                          _summaryItem(
                                            title: 'Left Points',
                                            value: refWatch.value?.leftPoints
                                                    ?.toString() ??
                                                '0',
                                            icon: Icons
                                                .account_balance_wallet_outlined,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader(String marketName, String gameName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.games, color: darkBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marketName,
                  style: GoogleFonts.rubik(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gameName,
                  style: GoogleFonts.rubik(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
      {required String title, required String value, required IconData icon}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Colors.black),
            const SizedBox(width: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  Future<bool> isStopGameExecution({
    required BuildContext context,
    required WidgetRef ref,
    required String marketId,
    required String gameName,
  }) async {
    // This is a placeholder function based on what appears to be used in your app
    // Actual implementation should match your app's requirements
    return false;
  }

  Widget chooseNumber(BuildContext context, String? number) {
    return Consumer(
      builder: (context, ref, _) {
        final refWatch = ref.watch(singleDigitBulkNotifierProvider).value;
        final value = refWatch?.singleDigitNewModel
                .firstWhere((element) => element.points == number)
                .value
                ?.text ??
            '';
        final refRead = ref.read(singleDigitBulkNotifierProvider.notifier);

        return InkWell(
          onTap: () async {
            HapticFeedback.mediumImpact();
            if (refWatch?.enteredPoints.text.isEmpty ?? true) {
              toast(
                context: context,
                "Please enter points",
              );
              return;
            }
            refRead.addPoints(context, number.toString());
          },
          child: Container(
            decoration: BoxDecoration(
              color: value.isNotEmpty ? Colors.green : darkBlue,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    number.toString(),
                    style: GoogleFonts.rubik(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (value.isNotEmpty)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        value,
                        style: GoogleFonts.rubik(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
