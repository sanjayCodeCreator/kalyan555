import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/everything_okay.dart';
import 'package:sm_project/features/games/open_close_component.dart';
import 'package:sm_project/features/games/sp_motor_game/sp_motor_game_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:text_marquee_widget/text_marquee_widget.dart';

class SpMotorGameScreen extends HookConsumerWidget {
  final String id;
  final String tag;
  final String name;
  const SpMotorGameScreen(
      {super.key, required this.id, required this.tag, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refWatch = ref.watch(spMotorGameNotifierProvider);
    final refRead = ref.read(spMotorGameNotifierProvider.notifier);
    final getParticularRef =
        ref.read(getParticularPlayerNotifierProvider.notifier);
    useEffect(() {
      getParticularRef.getParticularPlayerModel(context: context);
      Future.microtask(() => refRead.refreshWalletData(context, ref));
      return null;
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
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                if (isStopGameExecution(
                    context: context,
                    ref: ref,
                    marketId: id,
                    gameName: "SP Motor")) {
                  return;
                }

                // Use the onSubmitConfirm method from notifier instead of just showing a snackbar
                if (refWatch.selectedNumberList.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please add at least one bid')),
                  );
                  return;
                }
                refRead.onSubmitConfirm(context, tag, id, ref);
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
                  'CONFIRM',
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button and wallet
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
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: darkBlue,
                          child: const Icon(
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
                            "$name, SP Motor",
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Consumer(builder: (context, ref, _) {
                        final refWatchWallet =
                            ref.watch(getParticularPlayerNotifierProvider);
                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.pushNamed(RouteNames.deposit);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF0F8FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: darkBlue.withOpacity(0.2))),
                            child: Row(children: [
                              Image.asset(
                                walletLogo,
                                height: 18,
                                width: 18,
                                color: darkBlue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                  refWatchWallet.value?.getParticularPlayerModel
                                          ?.data?.wallet
                                          ?.toString() ??
                                      "",
                                  style: GoogleFonts.rubik(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: darkBlue))
                            ]),
                          ),
                        );
                      }),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Main card for inputs
                Card(
                  color: Colors.white,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.grey, width: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OpenCloseComponent(marketId: id),
                        const SizedBox(height: 10),
                        Text(
                          "SP Motor",
                          style: GoogleFonts.rubik(
                            color: darkBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return motorList;
                            }
                            return motorList.where((option) => option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (String selection) {
                            refRead.updateEnteredNumber(selection);
                          },
                          fieldViewBuilder: (context, textEditingController,
                              focusNode, onFieldSubmitted) {
                            // Keep controller in sync with state
                            textEditingController.text =
                                refWatch.enteredNumber.text;
                            textEditingController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: textEditingController.text.length));

                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'Enter SP Motor',
                                border: const OutlineInputBorder(),
                                enabledBorder: const OutlineInputBorder(),
                                focusedBorder: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: GoogleFonts.rubik(
                                    color: Colors.grey, fontSize: 13),
                                suffixIcon: Icon(Icons.arrow_drop_down,
                                    color: darkBlue, size: 18),
                              ),
                              style: GoogleFonts.rubik(
                                decoration: TextDecoration.none,
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (value) {
                                refRead.updateEnteredNumber(value);
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 3.0,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  constraints:
                                      const BoxConstraints(maxHeight: 150),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.white,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    itemCount: options.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      final option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: ListTile(
                                          title: Text(
                                            option,
                                            style: GoogleFonts.rubik(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Points",
                          style: GoogleFonts.rubik(
                            color: darkBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: refWatch.enteredPoints,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter Points',
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: GoogleFonts.rubik(
                                color: Colors.grey, fontSize: 13),
                          ),
                          style: GoogleFonts.rubik(
                            decoration: TextDecoration.none,
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          onChanged: refRead.updateEnteredPoints,
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            refRead.addPoints(context, ref);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text('ADD BID',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.rubik(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Information section - simplified version since the state doesn't track selected numbers
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
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
                  child: Column(children: [
                    // Title
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        'Game Details',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Game info
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.15),
                          width: 0.7,
                        ),
                      ),
                      child: Consumer(builder: (context, ref, child) {
                        final refWatch = ref.watch(spMotorGameNotifierProvider);
                        return Column(
                          children: [
                            _infoItem(
                              title: 'Session',
                              value: refWatch.session,
                              icon: Icons.access_time,
                            ),
                            const SizedBox(height: 6),
                            _infoItem(
                              title: 'SP Motor',
                              value: refWatch.enteredNumber.text.isEmpty
                                  ? 'Not specified'
                                  : refWatch.enteredNumber.text,
                              icon: Icons.format_list_numbered,
                            ),
                            const SizedBox(height: 6),
                            _infoItem(
                              title: 'Points',
                              value: refWatch.enteredPoints.text.isEmpty
                                  ? '0'
                                  : refWatch.enteredPoints.text,
                              icon: Icons.payments_outlined,
                            ),
                          ],
                        );
                      }),
                    ),
                    // Selected bids section
                    if (refWatch.selectedNumberList.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: darkBlue,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'Selected Bids',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                            width: 0.7,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 4),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'S.No',
                                      style: GoogleFonts.rubik(
                                        fontWeight: FontWeight.w600,
                                        color: darkBlue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Session',
                                      style: GoogleFonts.rubik(
                                        fontWeight: FontWeight.w600,
                                        color: darkBlue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Number',
                                      style: GoogleFonts.rubik(
                                        fontWeight: FontWeight.w600,
                                        color: darkBlue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Points',
                                      style: GoogleFonts.rubik(
                                        fontWeight: FontWeight.w600,
                                        color: darkBlue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 28),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: refWatch.selectedNumberList.length,
                              itemBuilder: (context, index) {
                                final item = refWatch.selectedNumberList[index];
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 4),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '${index + 1}',
                                              style: GoogleFonts.rubik(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.session ?? '',
                                              style: GoogleFonts.rubik(
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.points ?? '',
                                              style: GoogleFonts.rubik(
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.value ?? '',
                                              style: GoogleFonts.rubik(
                                                  fontSize: 12),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              refRead.removePoints(
                                                  context, index);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (index <
                                        refWatch.selectedNumberList.length - 1)
                                      const Divider(height: 1),
                                  ],
                                );
                              },
                            ),
                            if (refWatch.selectedNumberList.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        refRead.deleteAll(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.07),
                                              blurRadius: 1,
                                              offset: const Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 13,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              'Delete All',
                                              style: GoogleFonts.rubik(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    // Summary section
                    Container(
                      margin: const EdgeInsets.only(top: 10),
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
                      child: Column(children: [
                        Text(
                          'Game Summary',
                          style: GoogleFonts.rubik(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Consumer(builder: (context, ref, child) {
                          final refWatch =
                              ref.watch(spMotorGameNotifierProvider);
                          // Add total bids and total points to the summary
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _summaryItem(
                                    title: 'Market',
                                    value: name,
                                    icon: Icons.store,
                                  ),
                                  _summaryItem(
                                    title: 'Total Bids',
                                    value:
                                        refWatch.totalSelectedNumber.toString(),
                                    icon: Icons.confirmation_number,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _summaryItem(
                                    title: 'Total Points',
                                    value: refWatch.totalPoints.toString(),
                                    icon: Icons.monetization_on,
                                  ),
                                  _summaryItem(
                                    title: 'Wallet Balance',
                                    value: refWatch.leftPoints.toString(),
                                    icon: Icons.account_balance_wallet,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ]),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(
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
            borderRadius: BorderRadius.circular(14),
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

  Widget _infoItem(
      {required String title, required String value, required IconData icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: darkBlue),
            const SizedBox(width: 5),
            Text(
              title,
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 0.7,
            ),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.rubik(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}
