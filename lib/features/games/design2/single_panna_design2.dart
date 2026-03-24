import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/games/single_panna/single_panna_list.dart';
import 'package:sm_project/features/games/single_panna/single_panna_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

import '../../../controller/riverpod/auth_notifier/get_a_particular_notifier.dart';

class SinglePannaDesign2 extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  const SinglePannaDesign2(
      {super.key, this.tag, this.marketId, this.marketName});

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
                      gameName: "Single Panna")) {
                    return;
                  }
                  ref
                      .read(singlePannaNotifierProvider.notifier)
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
                    child: Text('CONFIRM',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ))),
              ),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 6),
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
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextMarqueeWidget(
                        child: Text(
                          "${marketName ?? ""}, Single Panna",
                          style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
                                      color: darkBlue))
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
              Consumer(builder: (context, ref, child) {
                final refRead = ref.read(singlePannaNotifierProvider.notifier);
                final refWatch = ref.read(singlePannaNotifierProvider).value;
                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "Single Panna",
                          style: GoogleFonts.rubik(
                            color: darkBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        LayoutBuilder(builder: (context, constraints) {
                          return RawAutocomplete(
                            textEditingController: refWatch?.enteredNumber,
                            focusNode: FocusNode(),
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<String>.empty();
                              } else {
                                List<String> matches = <String>[];
                                matches.addAll(singlePannaList);
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
                                maxLength: 3,
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
                                    decoration: TextDecoration.none,
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  enabledBorder: const OutlineInputBorder(),
                                  focusedBorder: const OutlineInputBorder(),
                                  hintText: "Select Panna Number",
                                  hintStyle: GoogleFonts.rubik(
                                    color: Colors.grey.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
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
                                                style: GoogleFonts.rubik(
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
                        Text(
                          "Points",
                          style: GoogleFonts.rubik(
                            color: darkBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        TextFormField(
                          controller: refWatch?.enteredPoints,
                          focusNode: FocusNode(),
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.rubik(
                            decoration: TextDecoration.none,
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(),
                            hintText: "Enter Points",
                            hintStyle: GoogleFonts.rubik(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 16,
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
                        const SizedBox(height: 20),
                        Consumer(builder: (context, ref, child) {
                          return InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(singlePannaNotifierProvider.notifier)
                                  .addPoints(context);
                            },
                            child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                            InkWell(
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                ref
                                    .read(singlePannaNotifierProvider.notifier)
                                    .deleteAll(context);
                              },
                              child: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                    ],
                  ),
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
                      final refWatch = ref.watch(singlePannaNotifierProvider);
                      final refRead =
                          ref.read(singlePannaNotifierProvider.notifier);
                      return refWatch.value?.selectedNumberList.isEmpty ?? true
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
                              itemCount:
                                  refWatch.value?.selectedNumberList.length ??
                                      0,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 20, thickness: 0.5),
                              itemBuilder: (context, index) {
                                return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 5),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.3)),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
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
                                                fontWeight: FontWeight.bold,
                                                color: darkBlue,
                                              ))),
                                      Container(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 5, 10, 5),
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.3)),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
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
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ))),
                                      InkWell(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          refRead.removePoints(context, index);
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 8, 8, 8),
                                            decoration: BoxDecoration(
                                                color:
                                                    Colors.red.withOpacity(0.1),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.red
                                                        .withOpacity(0.3)),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Icon(Icons.delete,
                                                color: Colors.red, size: 20)),
                                      )
                                    ]);
                              });
                    }),
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
                        final refWatch = ref.watch(singlePannaNotifierProvider);
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
                                value: refWatch.value?.totalPoints.toString() ??
                                    '0',
                                icon: Icons.payments_outlined,
                              ),
                              _summaryItem(
                                title: 'Left Points',
                                value: refWatch.value?.leftPoints.toString() ??
                                    '0',
                                icon: Icons.account_balance_wallet_outlined,
                              ),
                            ]);
                      }),
                    ]),
                  ),
                ]),
              ),
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
      BuildContext context, String? number, SinglePannaModel? onChangedValue) {
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
                style: GoogleFonts.rubik(
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
              // focusNode: FocusNode(),
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
                log('onChangedValue: $onChangedValue');
              },
            ))
      ],
    );
  }
}
