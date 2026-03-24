import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/jodi_bulk/jodi_bulk_notifier.dart';
import 'package:sm_project/features/games/jodi_digit/jodi_digit_list.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

class JodiBulkScreen extends HookConsumerWidget {
  final String id;
  final String tag;
  final String name;
  const JodiBulkScreen({
    required this.id,
    required this.tag,
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refRead = ref.read(getParticularPlayerNotifierProvider.notifier);
    useEffect(() {
      refRead.getParticularPlayerModel(context: context);
      return;
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
                  gameName: "Jodi Bulk",
                )) {
                  return;
                }
                if (context.mounted) {
                  ref
                      .read(jodiBulkNotifierProvider.notifier)
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
                          const SizedBox(width: 6),
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
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextMarqueeWidget(
                              child: Text(
                                "$name, Jodi Bulk",
                                style: GoogleFonts.rubik(
                                  color: Colors.black,
                                  fontSize: 16,
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
                                          fontWeight: FontWeight.bold,
                                          color: darkBlue,
                                        ))
                                  ]),
                                ));
                          }),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Consumer(
                      builder: (context, ref, child) {
                        final refWatch = ref.watch(jodiBulkNotifierProvider);
                        final refRead = ref.read(
                          jodiBulkNotifierProvider.notifier,
                        );
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:  BorderSide(
                                            color: darkBlue,
                                          ),
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
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Jodi",
                                    style: GoogleFonts.rubik(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return RawAutocomplete(
                                          textEditingController:
                                              refWatch.value?.enteredNumber,
                                          focusNode: FocusNode(),
                                          optionsBuilder: (
                                            TextEditingValue textEditingValue,
                                          ) {
                                            if (textEditingValue.text == '') {
                                              return const Iterable<
                                                  String>.empty();
                                            } else {
                                              List<String> matches = <String>[];
                                              matches.addAll(jodiDigitList);
                                              matches.retainWhere(
                                                (String s) =>
                                                    s.toLowerCase().startsWith(
                                                          textEditingValue.text
                                                              .toLowerCase(),
                                                        ),
                                              );
                                              return matches;
                                            }
                                          },
                                          onSelected: (String selection) {
                                            refRead.updateEnteredNumber(
                                              selection,
                                            );
                                          },
                                          fieldViewBuilder: (
                                            BuildContext context,
                                            TextEditingController
                                                textEditingController,
                                            FocusNode focusNode,
                                            VoidCallback onFieldSubmitted,
                                          ) {
                                            return TextFormField(
                                              enableInteractiveSelection: false,
                                              textAlign: TextAlign.start,
                                              controller: textEditingController,
                                              keyboardType:
                                                  TextInputType.number,
                                              focusNode: focusNode,
                                              maxLength: 2,
                                              onFieldSubmitted: (value) {
                                                onFieldSubmitted();
                                              },
                                              buildCounter: (
                                                context, {
                                                required currentLength,
                                                required isFocused,
                                                required maxLength,
                                              }) {
                                                return const SizedBox();
                                              },
                                              style: GoogleFonts.rubik(
                                                decoration: TextDecoration.none,
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8,
                                                  ),
                                                  borderSide: BorderSide(
                                                    color: Colors.grey
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    8,
                                                  ),
                                                  borderSide:  BorderSide(
                                                    color: darkBlue,
                                                  ),
                                                ),
                                                hintText: "Jodi",
                                                hintStyle: GoogleFonts.rubik(
                                                  color: Colors.grey
                                                      .withOpacity(0.7),
                                                  fontSize: 12,
                                                ),
                                                isDense: true,
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                              onChanged: (value) {
                                                if (value.length == 2) {
                                                  HapticFeedback.mediumImpact();
                                                  ref
                                                      .read(
                                                        jodiBulkNotifierProvider
                                                            .notifier,
                                                      )
                                                      .addPoints(context);
                                                }
                                              },
                                            );
                                          },
                                          optionsViewBuilder: (
                                            BuildContext context,
                                            void Function(String) onSelected,
                                            Iterable<String> options,
                                          ) {
                                            return Align(
                                              alignment: Alignment.topLeft,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: constraints
                                                        .biggest.width,
                                                    height: MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        0.18,
                                                    margin:
                                                        const EdgeInsets.only(
                                                      top: 0,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8,
                                                      ),
                                                    ),
                                                    child: ListView.builder(
                                                      itemCount: options.length,
                                                      shrinkWrap: true,
                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        return InkWell(
                                                          onTap: () {
                                                            onSelected(
                                                              options.elementAt(
                                                                index,
                                                              ),
                                                            );
                                                          },
                                                          child: ListTile(
                                                            title: Text(
                                                              options.elementAt(
                                                                index,
                                                              ),
                                                              style: GoogleFonts
                                                                  .rubik(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    return InkWell(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        ref
                                            .read(
                                              jodiBulkNotifierProvider.notifier,
                                            )
                                            .addPoints(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: darkBlue,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.08),
                                              blurRadius: 2,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          "ADD",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.rubik(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Selected Numbers",
                      style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: darkBlue,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Number",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Points",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "Remove",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final refWatch = ref.watch(
                                    jodiBulkNotifierProvider,
                                  );
                                  final refRead = ref.read(
                                    jodiBulkNotifierProvider.notifier,
                                  );

                                  if (refWatch
                                          .value?.selectedNumberList.isEmpty ??
                                      true) {
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
                                                            6),
                                                  ),
                                                  child: Text(
                                                    item?.points ?? '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    item?.value ?? '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green[700],
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    refRead.removePoints(
                                                      context,
                                                      index,
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
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
                            const SizedBox(height: 6),
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final refWatch =
                                          ref.watch(jodiBulkNotifierProvider);
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _summaryItem(
                                            context,
                                            title: "Bids",
                                            value: refWatch
                                                    .value?.totalSelectedNumber
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

  Widget _summaryItem(BuildContext context,
      {required String title, required String value, required IconData icon}) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.black),
            const SizedBox(width: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 10,
                fontWeight: FontWeight.bold,
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}
