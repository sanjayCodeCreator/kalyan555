import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/features/card_jackpot/jackpot_card_selector_notifier.dart';
import 'package:sm_project/utils/all_images.dart';
import 'package:sm_project/utils/colors.dart';

class JackpotCardSelectorComponent extends StatelessWidget {
  const JackpotCardSelectorComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Consumer(builder: (context, ref, child) {
          final String selectedCard =
              ref.watch(jackpotCardSelectorNotifierProvider).value ?? "";
          final refRead =
              ref.read(jackpotCardSelectorNotifierProvider.notifier);
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    refRead.updateCardSelection("Hearts");
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: selectedCard == "Hearts" ? darkBlue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedCard == "Hearts"
                            ? const Color(0xffffe70b)
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            selectedCard == "Hearts"
                                ? activeHeartIcon
                                : inactiveHeartIcon,
                            width: 45,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Hearts",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    refRead.updateCardSelection("Diamonds");
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                          selectedCard == "Diamonds" ? darkBlue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedCard == "Diamonds"
                            ? const Color(0xffffe70b)
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            selectedCard == "Diamonds"
                                ? activeDiamondIcon
                                : inactiveDiamondIcon,
                            width: 45,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Diamonds",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    refRead.updateCardSelection("Spades");
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: selectedCard == "Spades" ? darkBlue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedCard == "Spades"
                            ? const Color(0xffffe70b)
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            selectedCard == "Spades"
                                ? activeSpadeIcon
                                : inactiveSpadeIcon,
                            width: 45,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Spades",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    refRead.updateCardSelection("Clubs");
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: selectedCard == "Clubs" ? darkBlue : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedCard == "Clubs"
                            ? const Color(0xffffe70b)
                            : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            selectedCard == "Clubs"
                                ? activeClubIcon
                                : inactiveClubIcon,
                            width: 45,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Clubs",
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
