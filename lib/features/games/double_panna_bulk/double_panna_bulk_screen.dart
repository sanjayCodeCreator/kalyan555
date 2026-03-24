import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

import 'double_panna_bulk_notifier.dart';

class DoublePanaBulkScreen extends HookConsumerWidget {
  final String id;
  final String tag;
  final String name;
  const DoublePanaBulkScreen({
    super.key,
    required this.id,
    required this.tag,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ApiService().getParticularUserData();
      });
      return null;
    }, []);

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
                if (isStopGameExecution(
                  context: context,
                  ref: ref,
                  marketId: id,
                  gameName: "Double Panna Bulk",
                )) {
                  return;
                }
                if (context.mounted) {
                  ref
                      .read(doublePanaBulkNotifierProvider.notifier)
                      .onSubmitConfirm(context, tag, id);
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
                      color: Colors.black.withOpacity(0.1),
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
                          const SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child:  CircleAvatar(
                              radius: 16,
                              backgroundColor: darkBlue,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextMarqueeWidget(
                              child: Text(
                                "$name, Double Panna Bulk",
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
                                      borderRadius: BorderRadius.circular(12),
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
                          const SizedBox(width: 5),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    OpenCloseComponent(
                      marketId: id,
                    ),
                    const SizedBox(height: 5),
                    Consumer(
                      builder: (context, ref, child) {
                        final refWatch =
                            ref.watch(doublePanaBulkNotifierProvider);
                        final refRead = ref.read(
                          doublePanaBulkNotifierProvider.notifier,
                        );
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      controller: refWatch.value?.enteredPoints,
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
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          borderSide:  BorderSide(
                                            color: darkBlue,
                                          ),
                                        ),
                                        hintText: "Enter Points",
                                        hintStyle: GoogleFonts.rubik(
                                          color: Colors.grey.withOpacity(0.7),
                                          fontSize: 11,
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
                              const SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 10,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: (context, index) {
                                  return chooseNumber(
                                    context,
                                    index.toString(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Selected Numbers",
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                color: darkBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Panna",
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
                            const SizedBox(height: 5),
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final selectedNumbers = ref
                                          .watch(doublePanaBulkNotifierProvider)
                                          .value
                                          ?.selectedNumberList ??
                                      [];

                                  final refRead = ref.read(
                                    doublePanaBulkNotifierProvider.notifier,
                                  );

                                  if (selectedNumbers.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No numbers selected yet",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.rubik(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: selectedNumbers.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final item = selectedNumbers[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 5,
                                        ),
                                        child: Card(
                                          margin: EdgeInsets.zero,
                                          color: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            side: BorderSide(
                                                color: Colors.grey
                                                    .withOpacity(0.15)),
                                          ),
                                          child: Padding(
                                            key: ValueKey(index),
                                            padding: const EdgeInsets.all(6.0),
                                            child: Row(
                                              key: ValueKey(index),
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
                                                            6),
                                                  ),
                                                  child: Text(
                                                    item.points ?? '',
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
                                                            6),
                                                  ),
                                                  child: Text(
                                                    item.value ?? '',
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
                                                            6),
                                                  ),
                                                  child: Text(
                                                    item.session ?? '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  key: ValueKey(index),
                                                  onTap: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    refRead.removePoints(
                                                      context,
                                                      item.points ?? '',
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
                                                              6),
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
                            const SizedBox(height: 5),
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
                                    blurRadius: 1,
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
                                          doublePanaBulkNotifierProvider);
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _summaryItem(
                                            context,
                                            title: "Bids",
                                            value: refWatch.value
                                                    ?.selectedNumberList.length
                                                    .toString() ??
                                                '0',
                                            icon: Icons.format_list_numbered,
                                          ),
                                          _summaryItem(
                                            context,
                                            title: "Points",
                                            value: refWatch.value?.totalPoints
                                                    .toString() ??
                                                '0',
                                            icon: Icons.payments_outlined,
                                          ),
                                          _summaryItem(
                                            context,
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

  Widget chooseNumber(BuildContext context, String number) {
    return Consumer(
      builder: (context, ref, _) {
        final refWatch = ref.watch(doublePanaBulkNotifierProvider).value;
        final refRead = ref.read(doublePanaBulkNotifierProvider.notifier);
        return InkWell(
          onTap: () async {
            if (refWatch?.enteredPoints.text.isEmpty ?? true) {
              toast(context: context, "Please Enter Points");
              return;
            }
            HapticFeedback.mediumImpact();
            refRead.addPoints(context, number);
          },
          child: Container(
            decoration: BoxDecoration(
              color: darkBlue,
              border: Border.all(color: Colors.black, width: 0.5),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Center(
              child: Text(
                number,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryItem(BuildContext context,
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
            borderRadius: BorderRadius.circular(12),
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
}
