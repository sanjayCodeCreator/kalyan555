import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/games/triple_panna/triple_panna_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

class TriplePanna extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  const TriplePanna({super.key, this.tag, this.marketId, this.marketName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel(context: context);
      return;
    }, []);
    return BackgroundWrapper(
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: darkBlue,
            elevation: 0,
          ),
          backgroundColor: lightGreyColor,
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  if (isStopGameExecution(
                      context: context,
                      ref: ref,
                      marketId: marketId ?? '',
                      gameName: "Triple Panna")) {
                    return;
                  }
                  ref
                      .read(triplePannaNotifierProvider.notifier)
                      .onSubmitConfirm(context, tag ?? '', marketId ?? '');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'CONFIRM',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header with back button and wallet
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child:  CircleAvatar(
                        backgroundColor: darkBlue,
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextMarqueeWidget(
                        child: Text(
                          "${marketName ?? ""}, Triple Panna",
                          style: GoogleFonts.rubik(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
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
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF0F8FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: darkBlue.withOpacity(0.3))),
                            child: Row(children: [
                              Image.asset(
                                walletLogo,
                                height: 25,
                                width: 25,
                                color: darkBlue,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                  refWatch.value?.getParticularPlayerModel?.data
                                          ?.wallet
                                          ?.toString() ??
                                      "",
                                  style: GoogleFonts.rubik(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue,
                                  ))
                            ]),
                          ));
                    }),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              OpenCloseComponent(
                marketId: marketId ?? "",
              ),
              const SizedBox(height: 15),
              // Title for number grid
              Text(
                "Select Numbers",
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 5),
              Consumer(builder: (context, ref, child) {
                final refWatch = ref.watch(triplePannaNotifierProvider);
                return GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12.0,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 50,
                    ),
                    itemCount: refWatch.value?.numbers.length ?? 0,
                    itemBuilder: (context, index) {
                      final triplePanna = refWatch.value?.numbers[index];

                      return chooseNumber(
                        context,
                        triplePanna?.points.toString(),
                        triplePanna,
                      );
                    });
              }),
              const SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                return InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(triplePannaNotifierProvider.notifier)
                        .addPoints(context);
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text('ADD POINTS',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.rubik(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              )),
                        ],
                      )),
                );
              }),
              const SizedBox(height: 15),
              // Selected numbers section
              Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: whiteBackgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(children: [
                    // Title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Selected Numbers',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Session',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.rubik(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: darkBlue,
                                      ))),
                              Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Numbers',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.rubik(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: darkBlue,
                                      ))),
                              Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Points',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.rubik(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: darkBlue,
                                      ))),
                              InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  ref
                                      .read(
                                          triplePannaNotifierProvider.notifier)
                                      .deleteAll(context);
                                },
                                child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.delete_sweep,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                      ],
                                    )),
                              )
                            ]),

                        // List of numbers and points
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: whiteBackgroundColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Consumer(builder: (context, ref, child) {
                            final refWatch =
                                ref.watch(triplePannaNotifierProvider);
                            final refRead =
                                ref.read(triplePannaNotifierProvider.notifier);
                            return refWatch.value?.selectedNumberList.isEmpty ??
                                    true
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Text(
                                        "No numbers selected yet.\nSelect numbers and add points.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.rubik(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: refWatch
                                            .value?.selectedNumberList.length ??
                                        0,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                            height: 20, thickness: 0.5),
                                    itemBuilder: (context, index) {
                                      return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 5, 10, 5),
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF5F5F5),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                    refWatch
                                                                .value
                                                                ?.selectedNumberList[
                                                                    index]
                                                                .isClosed ??
                                                            false
                                                        ? 'Closed'
                                                        : 'Open',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ))),
                                            Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 5, 10, 5),
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF5F5F5),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                    refWatch
                                                            .value
                                                            ?.selectedNumberList[
                                                                index]
                                                            .points
                                                            .toString() ??
                                                        '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: darkBlue,
                                                    ))),
                                            Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 5, 10, 5),
                                                decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFF5F5F5),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                    refWatch
                                                            .value
                                                            ?.selectedNumberList[
                                                                index]
                                                            .value
                                                            .toString() ??
                                                        '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green,
                                                    ))),
                                            InkWell(
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                refRead.removePoints(
                                                    context, index);
                                              },
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          8, 8, 8, 8),
                                                  decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.1),
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors.red
                                                              .withOpacity(
                                                                  0.3)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 20)),
                                            )
                                          ]);
                                    });
                          }),
                        ),
                      ],
                    ),
                    // Summary section
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFC000)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(children: [
                        Text(
                          'Game Summary',
                          style: GoogleFonts.rubik(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer(builder: (context, ref, child) {
                          final refWatch =
                              ref.watch(triplePannaNotifierProvider);
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _summaryItem(
                                  title: 'Numbers',
                                  value: refWatch.value?.totalSelectedNumber
                                          .toString() ??
                                      '0',
                                  icon: Icons.format_list_numbered,
                                ),
                                _summaryItem(
                                  title: 'Points',
                                  value:
                                      refWatch.value?.totalPoints.toString() ??
                                          '0',
                                  icon: Icons.payments_outlined,
                                ),
                                _summaryItem(
                                  title: 'Left Points',
                                  value:
                                      refWatch.value?.leftPoints.toString() ??
                                          '0',
                                  icon: Icons.account_balance_wallet_outlined,
                                ),
                              ]);
                        }),
                      ]),
                    ),
                  ])),
              const SizedBox(height: 15),
            ]),
          ))),
    );
  }

  Widget _summaryItem(
      {required String title, required String value, required IconData icon}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  Widget chooseNumber(
      BuildContext context, String? number, TriplePannaModel? onChangedValue) {
    return Row(
      children: [
        Container(
          height: 45,
          width: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Card(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              elevation: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(number.toString(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      )),
                ),
              ),
            ),
          ),
        ),
        Consumer(builder: (context, ref, child) {
          final refGetSession = ref.watch(triplePannaNotifierProvider);
          return Container(
              height: 45,
              decoration: BoxDecoration(
                color: whiteBackgroundColor,
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width * 0.26,
              child: TextFormField(
                key: ValueKey(refGetSession.value?.startDigit),
                autofocus: false,
                focusNode: null,
                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center,
                controller: onChangedValue?.value,
                cursorColor: darkBlue,
                maxLines: 1,
                style: GoogleFonts.rubik(
                  fontSize: 20,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(top: 11),
                    isDense: true,
                    hintText: "Enter points",
                    hintStyle: GoogleFonts.rubik(
                      color: Colors.grey.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none),
                onChanged: (value) {
                  onChangedValue?.value?.text = value;
                  onChangedValue?.points = number.toString();
                },
              ));
        })
      ],
    );
  }
}
