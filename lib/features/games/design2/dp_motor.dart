import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/jodi_digit/jodi_digit_notifier.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/games/single_digit/single_digit_list.dart';
import 'package:sm_project/features/games/sp_dp_tp/dp_motor_notifier.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

class DPMotor extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  const DPMotor({this.marketName, this.tag, this.marketId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refRead = ref.read(getParticularPlayerNotifierProvider.notifier);
    useEffect(() {
      refRead.getParticularPlayerModel(context: context);
      ref.read(getSettingNotifierProvider.notifier).getSettingModel();
      return;
    }, []);
    return BackgroundWrapper(
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          backgroundColor: Colors.transparent,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 50.0, left: 16, right: 16.0),
            child: InkWell(
              onTap: () {
                if (isStopGameExecution(
                    context: context,
                    ref: ref,
                    marketId: marketId ?? '',
                    gameName: "SPDPTP")) {
                  return;
                }
                ref
                    .read(dpNotifierProvider.notifier)
                    .onSubmitConfirm(context, tag ?? '', marketId ?? '');
              },
              child: Container(
                  padding: const EdgeInsets.all(6),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: addConfirmButtonColor,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(2, 2),
                        color: darkBlue,
                      )
                    ],
                    borderRadius: BorderRadius.circular(0),
                  ),
                  child: const Text(
                    'Confirm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: addConfirmButtonForgroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  )),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
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
                      child: CircleAvatar(
                        backgroundColor: darkBlue,
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextMarqueeWidget(
                        child: Text(
                          "${marketName ?? ""}, DP Game",
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
              Consumer(builder: (context, ref, child) {
                final refWatch = ref.watch(dpNotifierProvider);
                final refRead = ref.read(dpNotifierProvider.notifier);
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 10),
                        // Row(
                        //   mainAxisAlignment:
                        //       MainAxisAlignment.spaceAround,
                        //   children: [
                        //     Row(
                        //       children: [
                        //         Checkbox(
                        //           value: refWatch.value?.isSPSelected,
                        //           onChanged: (value) {
                        //             refRead.changeSPDPTPCheckBox(
                        //                 "SP", value ?? false);
                        //           },
                        //         ),
                        //         const Text(
                        //           "SP",
                        //         ),
                        //       ],
                        //     ),
                        //     Row(
                        //       children: [
                        //         Checkbox(
                        //           value: refWatch.value?.isDPSelected,
                        //           onChanged: (value) {
                        //             refRead.changeSPDPTPCheckBox(
                        //                 "DP", value ?? false);
                        //           },
                        //         ),
                        //         const Text(
                        //           "DP",
                        //         ),
                        //       ],
                        //     ),
                        //     Row(
                        //       children: [
                        //         Checkbox(
                        //           value: refWatch.value?.isTPSelected,
                        //           onChanged: (value) {
                        //             refRead.changeSPDPTPCheckBox(
                        //                 "TP", value ?? false);
                        //           },
                        //         ),
                        //         const Text(
                        //           "TP",
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 10),
                        const Text(
                          "DP Game",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        LayoutBuilder(builder: (context, constraints) {
                          return RawAutocomplete(
                            textEditingController:
                                refWatch.value?.enteredNumber,
                            focusNode: FocusNode(),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              } else {
                                List<String> matches = <String>[];
                                matches.addAll(singleDigitList);
                                matches.retainWhere((String s) => s
                                    .toLowerCase()
                                    .startsWith(
                                        textEditingValue.text.toLowerCase()));
                                return matches;
                              }
                            },
                            onSelected: (String selection) {
                              refRead.updateEnteredNumber(selection);
                            },
                            fieldViewBuilder: (BuildContext context,
                                TextEditingController textEditingController,
                                FocusNode focusNode,
                                VoidCallback onFieldSubmitted) {
                              return TextFormField(
                                textAlign: TextAlign.start,
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
                                style: const TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(),
                                  hintText: "Select Digit Number",
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                onChanged: (value) {},
                              );
                            },
                            optionsViewBuilder: (BuildContext context,
                                void Function(String) onSelected,
                                Iterable<String> options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: constraints.biggest.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.25,
                                      margin: const EdgeInsets.only(top: 0),
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListView.builder(
                                        itemCount: options.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              onSelected(
                                                  options.elementAt(index));
                                            },
                                            child: ListTile(
                                              title: Text(
                                                options.elementAt(index),
                                                style: const TextStyle(
                                                    color: Colors.black),
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
                        }),
                        const SizedBox(height: 8),
                        const Text(
                          "Points",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: refWatch.value?.enteredPoints,
                          focusNode: FocusNode(),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            hintText: "Enter Points",
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              refRead.updateEnteredPoints(value);
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Consumer(builder: (context, ref, child) {
                          return InkWell(
                            onTap: () {
                              ref
                                  .read(dpNotifierProvider.notifier)
                                  .addPoints(context);
                            },
                            child: Container(
                                padding: const EdgeInsets.all(6),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: addConfirmButtonColor,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(2, 2),
                                      color: darkBlue,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: const Text('Add',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: addConfirmButtonForgroundColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900))),
                          );
                        }),
                      ],
                    ),
                  ),
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
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    ref
                                        .read(dpNotifierProvider.notifier)
                                        .deleteAll(context);
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 5, 10, 5),
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
                                ),
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
                            final refWatch = ref.watch(dpNotifierProvider);
                            final refRead =
                                ref.read(dpNotifierProvider.notifier);
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
                    const SizedBox(height: 15),
                    // Summary section
                    Container(
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
                          final refWatch = ref.watch(dpNotifierProvider);
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
      BuildContext context, String? number, JodiDigitModel? onChangedValue) {
    return Row(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.07,
          width: 50,
          decoration: const BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 17.0),
            child: Text(number.toString(),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                )),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: const BoxDecoration(
            color: whiteBackgroundColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          width: MediaQuery.of(context).size.width * 0.3,
          child: TextFormField(
            // initialValue: onChangedValue?.value?.text,
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.center,
            controller: onChangedValue?.value,
            cursorColor: darkBlue,
            maxLines: 1,
            style: const TextStyle(
                fontSize: 20, color: textColor, fontWeight: FontWeight.bold),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(top: 11),
                isDense: true,
                hintStyle: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none),

            onChanged: (value) {
              onChangedValue?.value?.text = value;
              onChangedValue?.points = number.toString();
              log('onChangedValue: $onChangedValue');
            },
          ),
        )
      ],
    );
  }
}
