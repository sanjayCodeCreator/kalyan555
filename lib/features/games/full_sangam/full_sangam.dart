import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/full_sangam/full_sangam_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

class FullSangam extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  const FullSangam({super.key, this.tag, this.marketId, this.marketName});

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
          backgroundColor: lightGreyColor,
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 50.0, left: 16, right: 16.0),
            child: Consumer(builder: (context, ref, child) {
              return InkWell(
                onTap: () {
                  if (isStopGameExecution(
                      context: context,
                      ref: ref,
                      marketId: marketId ?? '',
                      gameName: "Full Sangam")) {
                    return;
                  }
                  ref
                      .read(fullSangamNotifierProvider.notifier)
                      .onSubmitConfirm(context, tag ?? '', marketId ?? '');
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'Confirm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }),
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
                          "${marketName ?? ""}, Full Sangam",
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
              const SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: whiteBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Open Pana',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor)),
                ),
                Consumer(builder: (context, ref, child) {
                  final refWatch = ref.watch(fullSangamNotifierProvider);
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                      color: whiteBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: RawAutocomplete(
                      textEditingController: refWatch.value?.openPanaController,
                      focusNode: refWatch.value?.openfocusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        } else {
                          List<String> matches = <String>[];
                          matches.addAll(refWatch.value?.pana ?? []);
                          matches.retainWhere((String s) => s
                              .toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase()));

                          return matches;
                        }
                      },
                      onSelected: (String selection) {
                        refWatch.value?.openPanaController?.text = selection;
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
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
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(top: 5, left: 10.0),
                            border: InputBorder.none,
                          ),
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          void Function(String) onSelected,
                          Iterable<String> options) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: const BoxDecoration(
                                color: whiteBackgroundColor,
                              ),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(0),
                                itemCount: options.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      onSelected(options.elementAt(index));
                                    },
                                    child: ListTile(
                                      title: Text(options.elementAt(index)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                })
              ]),
              const SizedBox(height: 25),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: whiteBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Close Pana',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor)),
                ),
                Consumer(builder: (context, ref, child) {
                  final refWatch = ref.watch(fullSangamNotifierProvider);
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      color: whiteBackgroundColor,
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: RawAutocomplete(
                      textEditingController:
                          refWatch.value?.closePanaController,
                      focusNode: refWatch.value?.closefocusNode,
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        } else {
                          List<String> matches = <String>[];
                          matches.addAll(refWatch.value?.pana ?? []);
                          matches.retainWhere((String s) => s
                              .toLowerCase()
                              .startsWith(textEditingValue.text.toLowerCase()));

                          return matches;
                        }
                      },
                      onSelected: (String selection) {
                        refWatch.value?.closePanaController?.text =
                            selection.toString();
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController? textEditingController,
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(top: 5, left: 10.0),
                            border: InputBorder.none,
                          ),
                        );
                      },
                      optionsViewBuilder: (BuildContext context,
                          void Function(String) onSelected,
                          Iterable<String> options) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: const BoxDecoration(
                                color: whiteBackgroundColor,
                              ),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(0),
                                itemCount: options.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      onSelected(options.elementAt(index));
                                    },
                                    child: ListTile(
                                      title: Text(options.elementAt(index)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                })
              ]),
              const SizedBox(height: 25),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: whiteBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Enter Points',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor)),
                ),
                Consumer(builder: (context, ref, child) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    decoration: BoxDecoration(
                      color: whiteBackgroundColor,
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      textAlign: TextAlign.center,
                      controller: ref
                          .watch(fullSangamNotifierProvider)
                          .value
                          ?.pointsController,
                      cursorColor: darkBlue,
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 20,
                          color: textColor,
                          fontWeight: FontWeight.bold),
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
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  );
                })
              ]),
              const SizedBox(height: 20),
              Consumer(builder: (context, ref, child) {
                return InkWell(
                  onTap: () {
                    ref
                        .read(fullSangamNotifierProvider.notifier)
                        .addPoints(context);
                  },
                  child: Container(
                      padding: const EdgeInsets.all(6),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text('ADD',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900))),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text('Open\nPanna',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                              Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Text('Close\nPana',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                              Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10)),
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
                                        .read(
                                            fullSangamNotifierProvider.notifier)
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: whiteBackgroundColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Consumer(builder: (context, ref, child) {
                            final refWatch =
                                ref.watch(fullSangamNotifierProvider);
                            ref.read(fullSangamNotifierProvider.notifier);
                            return ListView.builder(
                                itemCount:
                                    refWatch.value?.selectedOpenList.length ??
                                        0,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
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
                                                      refWatch.value?.selectedOpenList[index]
                                                              .toString() ??
                                                          '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black))),
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
                                                      refWatch.value?.selectedCloseList[index]
                                                              .toString() ??
                                                          '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black))),
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
                                                      refWatch.value?.selectedPointsList[index]
                                                              .toString() ??
                                                          '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black))),
                                              Consumer(builder:
                                                  (context, ref, child) {
                                                return InkWell(
                                                  onTap: () {
                                                    ref
                                                        .read(
                                                            fullSangamNotifierProvider
                                                                .notifier)
                                                        .removePoints(
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
                              ref.watch(fullSangamNotifierProvider);
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(children: [
                                  const Text('Open\nPanna',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: buttonForegroundColor)),
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
                                  const Text('Close\nPana',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: buttonForegroundColor)),
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
                                      refWatch.value?.totalPoints.toString() ??
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
                                      refWatch.value?.leftPoints.toString() ??
                                          '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: buttonForegroundColor))
                                ]),
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
}
