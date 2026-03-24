import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/half_sangam/half_sangam_notifier.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

class HalfSangam extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  const HalfSangam({super.key, this.tag, this.marketId, this.marketName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel(context: context);
      return;
    }, []);
    return BackgroundWrapper(
      child: SafeArea(
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
                child: Consumer(builder: (context, ref, child) {
                  return InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (isStopGameExecution(
                          context: context,
                          ref: ref,
                          marketId: marketId ?? '',
                          gameName: "Half Sangam")) {
                        return;
                      }
                      ref
                          .read(halfSangamNotifierProvider.notifier)
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
                  );
                }),
              ),
            ),
            body: SafeArea(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                "${marketName ?? ""}, Half Sangam",
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
                                        refWatch.value?.getParticularPlayerModel
                                                ?.data?.wallet
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
                    // Game selection section
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Choose Game Type",
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 45,
                            child: DropdownButtonFormField(
                              value: "Open Digit, Close Panna",
                              items: [
                                "Open Digit, Close Panna",
                                "Close Digit, Open Panna"
                              ]
                                  .map((e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: GoogleFonts.rubik(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              padding: EdgeInsets.zero,
                              borderRadius: BorderRadius.circular(15),
                              onChanged: (value) {
                                if (value == "Open Digit, Close Panna") {
                                  ref
                                      .read(halfSangamNotifierProvider.notifier)
                                      .changeOpenDigitClosePanna(true);
                                } else {
                                  ref
                                      .read(halfSangamNotifierProvider.notifier)
                                      .changeOpenDigitClosePanna(false);
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                fillColor: whiteBackgroundColor,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:  BorderSide(color: darkBlue),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // First row - Digit selection
                          Consumer(builder: (context, ref, child) {
                            final isOpenDigitClosePanna = ref
                                    .watch(halfSangamNotifierProvider)
                                    .value
                                    ?.isOpenDigitClosePana ??
                                false;
                            return Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.38,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isOpenDigitClosePanna
                                        ? 'Open Digit'
                                        : "Close Digit",
                                    style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Consumer(builder: (context, ref, child) {
                                  final refWatch =
                                      ref.watch(halfSangamNotifierProvider);
                                  return Expanded(
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: whiteBackgroundColor,
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.grey.withOpacity(0.5)),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: RawAutocomplete(
                                        textEditingController:
                                            refWatch.value?.openDigitController,
                                        focusNode:
                                            refWatch.value?.openfocusNode,
                                        optionsBuilder: (TextEditingValue
                                            textEditingValue) {
                                          if (textEditingValue.text == '') {
                                            return const Iterable<
                                                String>.empty();
                                          } else {
                                            List<String> matches = <String>[];
                                            matches.addAll(
                                                refWatch.value?.openDigit ??
                                                    []);
                                            matches.retainWhere((String s) => s
                                                .toLowerCase()
                                                .startsWith(textEditingValue
                                                    .text
                                                    .toLowerCase()));

                                            return matches;
                                          }
                                        },
                                        onSelected: (String selection) {
                                          refWatch.value?.openDigitController
                                              ?.text = selection;
                                        },
                                        fieldViewBuilder: (BuildContext context,
                                            TextEditingController
                                                textEditingController,
                                            FocusNode focusNode,
                                            VoidCallback onFieldSubmitted) {
                                          return TextFormField(
                                            textAlign: TextAlign.center,
                                            controller: textEditingController,
                                            keyboardType: TextInputType.number,
                                            focusNode: focusNode,
                                            maxLength: 1,
                                            onFieldSubmitted: (value) {
                                              onFieldSubmitted();
                                            },
                                            buildCounter: (context,
                                                {required currentLength,
                                                required isFocused,
                                                required maxLength}) {
                                              return const SizedBox();
                                            },
                                            style: GoogleFonts.rubik(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.none,
                                            ),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              border: InputBorder.none,
                                            ),
                                          );
                                        },
                                        optionsViewBuilder: (BuildContext
                                                context,
                                            void Function(String) onSelected,
                                            Iterable<String> options) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.08,
                                                margin: const EdgeInsets.only(
                                                    top: 1),
                                                decoration: const BoxDecoration(
                                                  color: whiteBackgroundColor,
                                                ),
                                                child: ListView.builder(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  itemCount: options.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        onSelected(options
                                                            .elementAt(index));
                                                      },
                                                      child: ListTile(
                                                        title: Text(options
                                                            .elementAt(index)),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                })
                              ],
                            );
                          }),
                          const SizedBox(height: 15),

                          // Second row - Panna selection
                          Consumer(builder: (context, ref, child) {
                            final isOpenDigitClosePanna = ref
                                    .watch(halfSangamNotifierProvider)
                                    .value
                                    ?.isOpenDigitClosePana ??
                                false;
                            return Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.38,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                      isOpenDigitClosePanna
                                          ? 'Close Pana'
                                          : "Open Pana",
                                      style: GoogleFonts.rubik(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      )),
                                ),
                                const SizedBox(width: 15),
                                Consumer(builder: (context, ref, child) {
                                  final refWatch =
                                      ref.watch(halfSangamNotifierProvider);
                                  return Expanded(
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: whiteBackgroundColor,
                                        border: Border.all(
                                            width: 1,
                                            color:
                                                Colors.grey.withOpacity(0.5)),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.03),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: RawAutocomplete(
                                        textEditingController:
                                            refWatch.value?.closePanaController,
                                        focusNode:
                                            refWatch.value?.closefocusNode,
                                        optionsBuilder: (TextEditingValue
                                            textEditingValue) {
                                          if (textEditingValue.text == '') {
                                            return const Iterable<
                                                String>.empty();
                                          } else {
                                            List<String> matches = <String>[];
                                            matches.addAll(
                                                refWatch.value?.closePana ??
                                                    []);
                                            matches.retainWhere((String s) => s
                                                .toLowerCase()
                                                .startsWith(textEditingValue
                                                    .text
                                                    .toLowerCase()));

                                            return matches;
                                          }
                                        },
                                        onSelected: (String selection) {
                                          refWatch.value?.closePanaController
                                              ?.text = selection;
                                        },
                                        fieldViewBuilder: (BuildContext context,
                                            TextEditingController
                                                textEditingController,
                                            FocusNode focusNode,
                                            VoidCallback onFieldSubmitted) {
                                          return TextFormField(
                                            textAlign: TextAlign.center,
                                            controller: textEditingController,
                                            keyboardType: TextInputType.number,
                                            focusNode: focusNode,
                                            onFieldSubmitted: (value) {
                                              onFieldSubmitted();
                                            },
                                            style: GoogleFonts.rubik(
                                              decoration: TextDecoration.none,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                              border: InputBorder.none,
                                            ),
                                          );
                                        },
                                        optionsViewBuilder: (BuildContext
                                                context,
                                            void Function(String) onSelected,
                                            Iterable<String> options) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.3,
                                                margin: const EdgeInsets.only(
                                                    top: 1),
                                                decoration: const BoxDecoration(
                                                  color: whiteBackgroundColor,
                                                ),
                                                child: ListView.builder(
                                                  padding:
                                                      const EdgeInsets.all(0),
                                                  itemCount: options.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        onSelected(options
                                                            .elementAt(index));
                                                      },
                                                      child: ListTile(
                                                        title: Text(options
                                                            .elementAt(index)),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                })
                              ],
                            );
                          }),
                          const SizedBox(height: 15),

                          // Points row
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.38,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text('Enter Points',
                                    style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    )),
                              ),
                              const SizedBox(width: 15),
                              Consumer(builder: (context, ref, child) {
                                return Expanded(
                                  child: Container(
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.5)),
                                      color: whiteBackgroundColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: TextFormField(
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      textAlign: TextAlign.center,
                                      controller: ref
                                          .watch(halfSangamNotifierProvider)
                                          .value
                                          ?.pointsController,
                                      cursorColor: darkBlue,
                                      maxLines: 1,
                                      style: GoogleFonts.rubik(
                                        fontSize: 20,
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.only(top: 11),
                                        isDense: true,
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: Colors.grey),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                );
                              })
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Consumer(builder: (context, ref, child) {
                      return InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(halfSangamNotifierProvider.notifier)
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
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: whiteBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(children: [
                          Column(
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Consumer(builder: (context, ref, child) {
                                      final isOpenDigitClosePanna = ref
                                              .watch(halfSangamNotifierProvider)
                                              .value
                                              ?.isOpenDigitClosePana ??
                                          false;
                                      return Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 1, color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(
                                              isOpenDigitClosePanna
                                                  ? 'Open\nDigit'
                                                  : "Close\nDigit",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)));
                                    }),
                                    Consumer(builder: (context, ref, child) {
                                      final isOpenDigitClosePanna = ref
                                              .watch(halfSangamNotifierProvider)
                                              .value
                                              ?.isOpenDigitClosePana ??
                                          false;
                                      return Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(
                                          isOpenDigitClosePanna
                                              ? 'Close\nPana'
                                              : "Open\nPana",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      );
                                    }),
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 5, 10, 5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1, color: Colors.grey),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Text('Enter\nPoints',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black))),
                                    Consumer(builder: (context, ref, child) {
                                      return InkWell(
                                        onTap: () {
                                          ref
                                              .read(halfSangamNotifierProvider
                                                  .notifier)
                                              .deleteAll(context);
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                10, 5, 10, 5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Text('Delete\nAll',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.red))),
                                      );
                                    })
                                  ]),

                              const SizedBox(height: 10),

                              // List of numbers and points
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: whiteBackgroundColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Consumer(builder: (context, ref, child) {
                                  final refWatch =
                                      ref.watch(halfSangamNotifierProvider);
                                  ref.read(halfSangamNotifierProvider.notifier);
                                  return ListView.builder(
                                      itemCount: refWatch
                                              .value?.selectedOpenList.length ??
                                          0,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        padding:
                                                            const EdgeInsets.fromLTRB(
                                                                10, 5, 10, 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10)),
                                                        child: Text(refWatch.value?.selectedOpenList[index].toString() ?? '',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors.black))),
                                                    Container(
                                                        padding:
                                                            const EdgeInsets.fromLTRB(
                                                                10, 5, 10, 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10)),
                                                        child: Text(refWatch.value?.selectedCloseList[index].toString() ?? '',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors.black))),
                                                    Container(
                                                        padding:
                                                            const EdgeInsets.fromLTRB(
                                                                10, 5, 10, 5),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    10)),
                                                        child: Text(refWatch.value?.selectedPointsList[index].toString() ?? '',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors.black))),
                                                    Consumer(builder:
                                                        (context, ref, child) {
                                                      return InkWell(
                                                        onTap: () {
                                                          ref
                                                              .read(
                                                                  halfSangamNotifierProvider
                                                                      .notifier)
                                                              .removePoints(
                                                                  context,
                                                                  index);
                                                        },
                                                        child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .fromLTRB(
                                                                    10, 5, 10, 5),
                                                            decoration: BoxDecoration(
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        10)),
                                                            child: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red)),
                                                      );
                                                    })
                                                  ]),
                                              const SizedBox(height: 15),
                                            ]);
                                      });
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: yellowColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(children: [
                              Consumer(builder: (context, ref, child) {
                                final refWatch =
                                    ref.watch(halfSangamNotifierProvider);
                                return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(children: [
                                        Consumer(
                                            builder: (context, ref, child) {
                                          final isOpenDigitClosePanna = ref
                                                  .watch(
                                                      halfSangamNotifierProvider)
                                                  .value
                                                  ?.isOpenDigitClosePana ??
                                              false;
                                          return Text(
                                              isOpenDigitClosePanna
                                                  ? 'Open\nDigit'
                                                  : "Close\nDigit",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      buttonForegroundColor));
                                        }),
                                        const SizedBox(height: 2),
                                        Text(
                                            refWatch.value?.totalOpenDigit
                                                    .toString() ??
                                                '',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: buttonForegroundColor))
                                      ]),
                                      Column(children: [
                                        Consumer(
                                            builder: (context, ref, child) {
                                          final isOpenDigitClosePanna = ref
                                                  .watch(
                                                      halfSangamNotifierProvider)
                                                  .value
                                                  ?.isOpenDigitClosePana ??
                                              false;
                                          return Text(
                                              isOpenDigitClosePanna
                                                  ? 'Close\nPana'
                                                  : "Open\nPana",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: buttonForegroundColor,
                                              ));
                                        }),
                                        const SizedBox(height: 2),
                                        Text(
                                            refWatch.value?.totalClosePoints
                                                    .toString() ??
                                                '',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: buttonForegroundColor))
                                      ]),
                                      Column(children: [
                                        const Text('Total\nPoints',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: buttonForegroundColor)),
                                        const SizedBox(height: 2),
                                        Text(
                                            refWatch.value?.totalPoints
                                                    .toString() ??
                                                '',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: buttonForegroundColor))
                                      ]),
                                      Column(children: [
                                        const Text('Left\nPoints',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: buttonForegroundColor)),
                                        const SizedBox(height: 2),
                                        Text(
                                          refWatch.value?.leftPoints
                                                  .toString() ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: buttonForegroundColor,
                                          ),
                                        )
                                      ]),
                                    ]);
                              }),
                            ]),
                          ),
                        ])),
                    const SizedBox(height: 15),
                  ]),
            ))),
      ),
    );
  }
}
