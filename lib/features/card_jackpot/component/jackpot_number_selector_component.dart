import 'package:flutter/services.dart';
import 'package:sm_project/features/card_jackpot/component/payment_pop_up_component.dart';
import 'package:sm_project/utils/filecollection.dart';

class JackpotNumberSelectorComponent extends StatefulWidget {
  const JackpotNumberSelectorComponent({super.key});

  @override
  State<JackpotNumberSelectorComponent> createState() =>
      _JackpotNumberSelectorComponentState();
}

class _JackpotNumberSelectorComponentState
    extends State<JackpotNumberSelectorComponent> {
  List<JackpotNumberSelectorModel> jackpotNumberList1 = [
    JackpotNumberSelectorModel(number: "10", radial: [
      const Color(0xffD47FAF),
      const Color(0xffC91188),
    ]),
    JackpotNumberSelectorModel(number: "9", radial: [
      const Color(0xff9BCDC8),
      const Color(0xff53938D),
    ]),
    JackpotNumberSelectorModel(number: "8", radial: [
      const Color(0xffFFC600),
      const Color(0xffD67E24),
    ]),
    JackpotNumberSelectorModel(number: "7", radial: [
      const Color(0xffE0A0B3),
      const Color(0xffCF3D3D),
    ]),
    JackpotNumberSelectorModel(number: "6", radial: [
      const Color(0xff4F6E8C),
      const Color(0xff304B7A),
    ]),
  ];
  List<JackpotNumberSelectorModel> jackpotNumberList2 = [
    JackpotNumberSelectorModel(number: "5", radial: [
      const Color(0xffBB5CC9),
      const Color(0xff77479C),
    ]),
    JackpotNumberSelectorModel(number: "4", radial: [
      const Color(0xffC9DBDA),
      const Color(0xff879896),
    ]),
    JackpotNumberSelectorModel(number: "3", radial: [
      const Color(0xffD47FAF),
      const Color(0xffC91188),
    ]),
    JackpotNumberSelectorModel(number: "2", radial: [
      const Color(0xff9BCDC8),
      const Color(0xff53938D),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: darkBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: darkBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: jackpotNumberList1.length,
                  itemBuilder: (context, index) {
                    final jackpotNumber = jackpotNumberList1[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showPaymentPopUp(
                              context: context,
                              title: "NUMBER ${jackpotNumber.number}");
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                RadialGradient(colors: jackpotNumber.radial),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: const Offset(2, 7),
                                color: Colors.black.withOpacity(0.65),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              jackpotNumber.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: jackpotNumberList2.length,
                  itemBuilder: (context, index) {
                    final jackpotNumber = jackpotNumberList2[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          showPaymentPopUp(
                              context: context,
                              title: "NUMBER ${jackpotNumber.number}");
                        },
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient:
                                RadialGradient(colors: jackpotNumber.radial),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 12,
                                spreadRadius: 0,
                                offset: const Offset(2, 7),
                                color: Colors.black.withOpacity(0.65),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              jackpotNumber.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class JackpotNumberSelectorModel {
  final String number;
  final List<Color> radial;
  JackpotNumberSelectorModel({
    required this.number,
    required this.radial,
  });
}
