import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/double_panna/double_panna_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../../../utils/realtime_timer.dart';

class DoublePanna extends HookConsumerWidget {
  final String? tag;
  final String? marketId;
  final String? marketName;
  const DoublePanna({super.key, this.tag, this.marketId, this.marketName});

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
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                if (isStopGameExecution(
                    context: context, ref: ref, marketId: marketId ?? '',gameName: "Double Panna")) {
                  return;
                }
                ref
                    .read(doublePannaNotifierProvider.notifier)
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
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Card(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '$marketName - Double Panna',
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
              const Center(child: TimerComponent()),
              const SizedBox(height: 15),
              Consumer(builder: (context, ref, child) {
                final refWatch = ref.watch(doublePannaNotifierProvider);
                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 1; i <= 9; i++)
                            InkWell(
                                onTap: () {
                                  ref
                                      .read(
                                          doublePannaNotifierProvider.notifier)
                                      .setStartDigit(i);
                                },
                                child: SizedBox(
                                    height: 36,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 7),
                                      height: 36,
                                      width: 35,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: refWatch.value?.startDigit == i
                                            ? buttonColor
                                            : Colors.grey,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(i.toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  refWatch.value?.startDigit ==
                                                          i
                                                      ? whiteBackgroundColor
                                                      : textColor)),
                                    ))),
                        ]));
              }),
              const SizedBox(height: 15),
              Consumer(builder: (context, ref, child) {
                final refWatch = ref.watch(doublePannaNotifierProvider);
                return GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 2 / 0.85,
                            crossAxisCount: 2,
                            mainAxisSpacing: 2.0,
                            crossAxisSpacing: 2),
                    itemCount: refWatch.value?.getdoublePannaModel().length,
                    itemBuilder: (context, index) {
                      final doublePanna =
                          refWatch.value?.getdoublePannaModel()[index];

                      return chooseNumber(
                          context, doublePanna?.points.toString(), doublePanna);
                    });
              }),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  ref
                      .read(doublePannaNotifierProvider.notifier)
                      .addPoints(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkBlue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'ADD',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
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
                                  child: const Text('No.',
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
                                  child: const Text('Points',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                              InkWell(
                                onTap: () {
                                  ref
                                      .read(
                                          doublePannaNotifierProvider.notifier)
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
                                    child: const Text('Delete All',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red))),
                              )
                            ]),

                        // List of numbers and points
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: whiteBackgroundColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: Consumer(builder: (context, ref, child) {
                            final refWatch =
                                ref.watch(doublePannaNotifierProvider);
                            final refRead =
                                ref.read(doublePannaNotifierProvider.notifier);
                            return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    refWatch.value?.selectedNumberList.length ??
                                        0,
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
                                                      refWatch.value?.selectedNumberList[index].points
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
                                                      refWatch.value?.selectedNumberList[index].value
                                                              .toString() ??
                                                          '',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black))),
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
                                                          color: Colors.red)))
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
                              ref.watch(doublePannaNotifierProvider);
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(children: [
                                  const Text('Numbers',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: buttonForegroundColor)),
                                  const SizedBox(height: 2),
                                  Text(
                                      refWatch.value?.totalSelectedNumber
                                              .toString() ??
                                          '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: buttonForegroundColor))
                                ]),
                                Column(children: [
                                  const Text('Points',
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
                                  const Text('Left Points',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: buttonForegroundColor)),
                                  const SizedBox(height: 2),
                                  Text(
                                      refWatch.value?.leftPoints.toString() ??
                                          '0',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: buttonForegroundColor))
                                ]),
                              ]);
                        }),
                      ]),
                    )
                  ])),
              const SizedBox(height: 15),
            ]),
          ))),
    );
  }

  Widget chooseNumber(
      BuildContext context, String? number, DoublePannaModel? onChangedValue) {
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: whiteBackgroundColor)),
          ),
        ),
        Consumer(builder: (context, ref, child) {
          final refGetSession = ref.watch(doublePannaNotifierProvider);
          return Container(
            height: MediaQuery.of(context).size.height * 0.07,
            decoration: BoxDecoration(
              color: whiteBackgroundColor,
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            width: MediaQuery.of(context).size.width * 0.3,
            child: TextFormField(
              key: ValueKey(refGetSession.value?.startDigit),
              autofocus: false,
              focusNode: null,
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
              },
            ),
          );
        })
      ],
    );
  }
}
