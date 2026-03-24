import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';

import 'red_jodi_notifier.dart';

class RedJodiScreen extends HookConsumerWidget {
  final String id;
  final String tag;
  final String name;
  const RedJodiScreen({
    super.key,
    required this.id,
    required this.tag,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refRead = ref.read(getParticularPlayerNotifierProvider.notifier);
    useEffect(() {
      refRead.getParticularPlayerModel(context: context);
      return null;
    }, []);
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: lightGreyColor,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: lightGreyColor,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
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
                  gameName: "Red Jodi",
                )) {
                  return;
                }
                if (context.mounted) {
                  ref
                      .read(redJodiNotifierProvider.notifier)
                      .onSubmitConfirm(context, tag, id);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 3,
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
                            blurRadius: 6,
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
                            child: Text(
                              "$name, Red Jodi",
                              style: GoogleFonts.rubik(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Consumer(builder: (context, ref, _) {
                            final refWatch =
                                ref.watch(getParticularPlayerNotifierProvider);
                            return refWatch.when(
                              data: (data) => InkWell(
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
                                        data.getParticularPlayerModel?.data
                                                ?.wallet
                                                ?.toString() ??
                                            "0",
                                        style: GoogleFonts.rubik(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: darkBlue,
                                        ))
                                  ]),
                                ),
                              ),
                              loading: () => const SizedBox(
                                width: 100,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                              ),
                              error: (_, __) => InkWell(
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
                                    Text("0",
                                        style: GoogleFonts.rubik(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: darkBlue,
                                        ))
                                  ]),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Consumer(
                      builder: (context, ref, child) {
                        final refWatch = ref.watch(redJodiNotifierProvider);
                        return refWatch.when(
                          data: (data) => GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisExtent: 32,
                              mainAxisSpacing: 0.0,
                              crossAxisSpacing: 3,
                            ),
                            itemCount: data.numbers.length,
                            itemBuilder: (context, index) {
                              final redJodi = data.numbers[index];
                              return chooseNumber(
                                context,
                                redJodi.points.toString(),
                                redJodi,
                              );
                            },
                          ),
                          loading: () => const Center(
                              child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))),
                          error: (error, stack) => Center(
                              child: Text('Error: $error',
                                  style: const TextStyle(fontSize: 12))),
                        );
                      },
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Consumer(
                        builder: (context, ref, child) {
                          return InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(redJodiNotifierProvider.notifier)
                                  .addPoints(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 16),
                              decoration: BoxDecoration(
                                color: darkBlue,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    6,
                                    3,
                                    6,
                                    3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Ank',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    6,
                                    3,
                                    6,
                                    3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Point',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    6,
                                    3,
                                    6,
                                    3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Delete',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
                                  redJodiNotifierProvider,
                                );
                                final refRead = ref.read(
                                  redJodiNotifierProvider.notifier,
                                );

                                return refWatch.when(
                                  data: (data) {
                                    if (data.selectedNumberList.isEmpty) {
                                      return Center(
                                        child: Text(
                                          "No entries added yet",
                                          style: GoogleFonts.rubik(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      itemCount: data.selectedNumberList.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Card(
                                            margin: EdgeInsets.zero,
                                            color: Colors.white,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data
                                                            .selectedNumberList[
                                                                index]
                                                            .points ??
                                                        '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    data
                                                            .selectedNumberList[
                                                                index]
                                                            .value ??
                                                        '',
                                                    textAlign: TextAlign.center,
                                                    style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      color: Colors.black,
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
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                      size: 18,
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
                                  loading: () => const Center(
                                      child: SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))),
                                  error: (error, stack) => Center(
                                      child: Text('Error: $error',
                                          style:
                                              const TextStyle(fontSize: 12))),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFC000)],
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
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final refWatch =
                                        ref.watch(redJodiNotifierProvider);
                                    return refWatch.when(
                                      data: (data) => Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _summaryItem(
                                            context,
                                            title: "Bids",
                                            value: data.totalSelectedNumber
                                                .toString(),
                                            icon: Icons.format_list_numbered,
                                          ),
                                          _summaryItem(
                                            context,
                                            title: "Points",
                                            value: data.totalPoints.toString(),
                                            icon: Icons.payments_outlined,
                                          ),
                                          Consumer(
                                            builder: (context, ref, _) {
                                              final walletWatch = ref.watch(
                                                  getParticularPlayerNotifierProvider);
                                              return walletWatch.when(
                                                data: (walletData) =>
                                                    _summaryItem(
                                                  context,
                                                  title: 'Left Points',
                                                  value: walletData
                                                          .getParticularPlayerModel
                                                          ?.data
                                                          ?.wallet
                                                          ?.toString() ??
                                                      '0',
                                                  icon: Icons
                                                      .account_balance_wallet_outlined,
                                                ),
                                                loading: () => _summaryItem(
                                                  context,
                                                  title: 'Left Points',
                                                  value: '0',
                                                  icon: Icons
                                                      .account_balance_wallet_outlined,
                                                ),
                                                error: (_, __) => _summaryItem(
                                                  context,
                                                  title: 'Left Points',
                                                  value: '0',
                                                  icon: Icons
                                                      .account_balance_wallet_outlined,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      loading: () => const Center(
                                          child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2))),
                                      error: (error, stack) => Center(
                                          child: Text('Error: $error',
                                              style: const TextStyle(
                                                  fontSize: 12))),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
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
            Icon(icon, size: 13, color: Colors.black),
            const SizedBox(width: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 11,
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
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }

  Widget chooseNumber(
    BuildContext context,
    String? number,
    RedJodiModel? onChangedValue,
  ) {
    if (number == null || onChangedValue == null) {
      return const SizedBox();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 24,
          width: 38,
          decoration: BoxDecoration(
            color: darkBlue,
            border: Border.all(color: Colors.black),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          child: Center(
            child: Text(
              number,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.rubik(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: whiteBackgroundColor,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: whiteBackgroundColor,
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextFormField(
              enableInteractiveSelection: false,
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.start,
              controller: onChangedValue.value,
              cursorColor: darkBlue,
              maxLines: 1,
              style: GoogleFonts.rubik(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.only(
                  top: 2,
                  left: 6,
                  right: 6,
                ),
                hintStyle: Theme.of(
                  context,
                )
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey, fontSize: 10),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              onChanged: (value) {
                onChangedValue.value?.text = value;
                onChangedValue.points = number;
              },
            ),
          ),
        ),
      ],
    );
  }
}
