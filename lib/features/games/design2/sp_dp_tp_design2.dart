import 'dart:developer';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/jodi_digit/jodi_digit_notifier.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/games/single_digit/single_digit_list.dart';
import 'package:sm_project/features/games/sp_dp_tp/sp_dp_tp_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';

class SPDPTPDesign2 extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  const SPDPTPDesign2({this.marketName, this.tag, this.marketId, super.key});

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
          ),
          backgroundColor: lightGreyColor,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                if (isStopGameExecution(
                    context: context, ref: ref, marketId: marketId ?? '',gameName: "SPDPTP")) {
                  return;
                }
                ref
                    .read(spdptpNotifierProvider.notifier)
                    .onSubmitConfirm(context, tag ?? '', marketId ?? '');
              },
              child: Container(
                  padding: const EdgeInsets.all(6),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: addConfirmButtonColor,
                    boxShadow:  [
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
                   Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          '$marketName - SPDPTP',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 15),
              OpenCloseComponent(
                marketId: marketId ?? "",
              ),
              
              Consumer(builder: (context, ref, child) {
                final refWatch = ref.watch(spdptpNotifierProvider);
                final refRead = ref.read(spdptpNotifierProvider.notifier);
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: refWatch.value?.isSPSelected,
                                  onChanged: (value) {
                                    refRead.changeSPDPTPCheckBox(
                                        "SP", value ?? false);
                                  },
                                ),
                                const Text(
                                  "SP",
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: refWatch.value?.isDPSelected,
                                  onChanged: (value) {
                                    refRead.changeSPDPTPCheckBox(
                                        "DP", value ?? false);
                                  },
                                ),
                                const Text(
                                  "DP",
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: refWatch.value?.isTPSelected,
                                  onChanged: (value) {
                                    refRead.changeSPDPTPCheckBox(
                                        "TP", value ?? false);
                                  },
                                ),
                                const Text(
                                  "TP",
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "SPDPTP Game",
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
                                  .read(spdptpNotifierProvider.notifier)
                                  .addPoints(context);
                            },
                            child: Container(
                                padding: const EdgeInsets.all(6),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: addConfirmButtonColor,
                                  boxShadow:  [
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
              Card(
                margin: EdgeInsets.zero,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(children: [
                      Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Text('Numbers',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor))),
                                Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Text('Points',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textColor))),
                                InkWell(
                                  onTap: () {
                                    ref
                                        .read(spdptpNotifierProvider.notifier)
                                        .deleteAll(context);
                                  },
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        border: Border.all(
                                            width: 1, color: Colors.white),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: const Text(
                                      'Delete All',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  ),
                                )
                              ]),
                          const SizedBox(
                            height: 8,
                          ),

                          // List of numbers and points
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Consumer(builder: (context, ref, child) {
                              final refWatch =
                                  ref.watch(spdptpNotifierProvider);
                              final refRead =
                                  ref.read(spdptpNotifierProvider.notifier);
                              return ListView.builder(
                                  itemCount: refWatch
                                          .value?.selectedNumberList.length ??
                                      0,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
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
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10)),
                                                    child: Text(
                                                        refWatch.value?.selectedNumberList[index].points
                                                                .toString() ??
                                                            '',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: textColor))),
                                                Container(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            10, 5, 10, 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1,
                                                            color: Colors.grey),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10)),
                                                    child: Text(
                                                        refWatch.value?.selectedNumberList[index].value
                                                                .toString() ??
                                                            '',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: textColor))),
                                                InkWell(
                                                  onTap: () {
                                                    refRead.removePoints(
                                                        context, index);
                                                  },
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          10, 5, 10, 5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color:
                                                                  Colors.grey),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10)),
                                                      child: const Icon(
                                                          Icons.delete,
                                                          color: Colors.red)),
                                                )
                                              ]),
                                          const SizedBox(height: 15),
                                        ]);
                                  });
                            }),
                          ),
                        ],
                      ),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: yellowColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(children: [
                            Consumer(builder: (context, ref, child) {
                              final refWatch =
                                  ref.watch(spdptpNotifierProvider);
                              return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(children: [
                                      const Text('Numbers',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Text(
                                          refWatch.value?.totalSelectedNumber
                                                  .toString() ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))
                                    ]),
                                    Column(children: [
                                      const Text('Points',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Text(
                                          refWatch.value?.totalPoints
                                                  .toString() ??
                                              '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))
                                    ]),
                                    Column(children: [
                                      const Text('Left Points',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      const SizedBox(height: 2),
                                      Text(
                                          refWatch.value?.leftPoints
                                                  .toString() ??
                                              '0',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white))
                                    ]),
                                  ]);
                            }),
                          ]),
                        ),
                      ),
                    ])),
              ),
              const SizedBox(height: 15),
            ]),
          ))),
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
