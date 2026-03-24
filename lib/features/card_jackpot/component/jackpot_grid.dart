import 'package:flutter/services.dart';
import 'package:sm_project/features/card_jackpot/component/payment_pop_up_component.dart';
import 'package:sm_project/features/card_jackpot/jackpot_card_selector_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class JackpotGrid extends StatefulWidget {
  const JackpotGrid({super.key});

  @override
  State<JackpotGrid> createState() => _JackpotGridState();
}

class _JackpotGridState extends State<JackpotGrid> {
  List<JackpotGridModel> jackpotList = [
    JackpotGridModel(icon: ikkaHeartIcon, title: "Ikka of Hearts", radial: [
      const Color(0xff304B7A),
      const Color(0xff4F6E8C),
    ]),
    JackpotGridModel(icon: kingHeartIcon, title: "King of Hearts", radial: [
      const Color(0xff77479C),
      const Color(0xffBB5CC9),
    ]),
    JackpotGridModel(icon: queenHeartIcon, title: "Queen of Hearts", radial: [
      const Color(0xffD67E24),
      const Color(0xffFFC600),
    ]),
    JackpotGridModel(icon: jackHeartIcon, title: "Jack of Hearts", radial: [
      const Color(0xff53938D),
      const Color(0xff9BCDC8),
    ]),
  ];
  updateCard(WidgetRef ref) {
    final refWatch = ref.watch(jackpotCardSelectorNotifierProvider).value ?? "";
    switch (refWatch) {
      case "Hearts":
        jackpotList[0].icon = ikkaHeartIcon;
        jackpotList[0].title = "Ikka of Hearts";
        jackpotList[1].icon = kingHeartIcon;
        jackpotList[1].title = "King of Hearts";
        jackpotList[2].icon = queenHeartIcon;
        jackpotList[2].title = "Queen of Hearts";
        jackpotList[3].icon = jackHeartIcon;
        jackpotList[3].title = "Jack of Hearts";
        break;
      case "Diamonds":
        jackpotList[0].icon = ikkaDiamondIcon;
        jackpotList[0].title = "Ikka of Diamonds";
        jackpotList[1].icon = kingDiamondIcon;
        jackpotList[1].title = "King of Diamonds";
        jackpotList[2].icon = queenDiamondIcon;
        jackpotList[2].title = "Queen of Diamonds";
        jackpotList[3].icon = jackDiamondIcon;
        jackpotList[3].title = "Jack of Diamonds";
      case "Spades":
        jackpotList[0].icon = ikkaDiamondIcon;
        jackpotList[0].title = "Ikka of Spades";
        jackpotList[1].icon = kingDiamondIcon;
        jackpotList[1].title = "King of Spades";
        jackpotList[2].icon = queenDiamondIcon;
        jackpotList[2].title = "Queen of Spades";
        jackpotList[3].icon = jackDiamondIcon;
        jackpotList[3].title = "Jack of Spades";
      case "Clubs":
        jackpotList[0].icon = ikkaClubIcon;
        jackpotList[0].title = "Ikka of Clubs";
        jackpotList[1].icon = kingClubIcon;
        jackpotList[1].title = "King of Clubs";
        jackpotList[2].icon = queenClubIcon;
        jackpotList[2].title = "Queen of Clubs";
        jackpotList[3].icon = jackClubIcon;
        jackpotList[3].title = "Jack of Clubs";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      updateCard(ref);
      return GridView.builder(
        itemCount: jackpotList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 70,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final jackpot = jackpotList[index];
          return InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              showPaymentPopUp(
                  context: context, title: jackpot.title.toUpperCase());
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: RadialGradient(
                    focalRadius: 5,
                    radius: 2,
                    center: Alignment.center,
                    colors: jackpot.radial,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Image.asset(
                              jackpot.icon,
                              width: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          jackpot.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

class JackpotGridModel {
  String icon;
  String title;
  final List<Color> radial;
  JackpotGridModel({
    required this.icon,
    required this.title,
    required this.radial,
  });
}
