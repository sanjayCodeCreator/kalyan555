// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:sm_project/utils/filecollection.dart';

showJackpotRates({required BuildContext context}) {
  final size = MediaQuery.of(context).size;
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        title: SizedBox(
          width: size.width * 0.8,
          child:  Text(
            "CARDS JACKPOT RATES",
            style: TextStyle(
              fontSize: 23,
              color: darkBlue,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
              decorationColor: darkBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: SizedBox(
            width: size.width * 0.8, child: const JackpotRatesComponent()),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                fixedSize: Size(size.width * 7, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                )),
            onPressed: () {
              context.pop();
            },
            child: const Text(
              "Ok",
              style: TextStyle(
                color: textColor,
                fontSize: 20,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class JackpotRatesComponent extends StatefulWidget {
  const JackpotRatesComponent({super.key});

  @override
  State<JackpotRatesComponent> createState() => _JackpotRatesComponentState();
}

class _JackpotRatesComponentState extends State<JackpotRatesComponent> {
  List<JackpotRatesModel> jackpotRatesModelList = [
    JackpotRatesModel(cardName: "Ikka", rate: "10-10"),
    JackpotRatesModel(cardName: "King", rate: "10-1500"),
    JackpotRatesModel(cardName: "Queen", rate: "10-3000"),
    JackpotRatesModel(cardName: "Jack", rate: "10-7000"),
    JackpotRatesModel(cardName: "10", rate: "10-10"),
    JackpotRatesModel(cardName: "9", rate: "10-1500"),
    JackpotRatesModel(cardName: "8", rate: "10-3000"),
    JackpotRatesModel(cardName: "7", rate: "10-7000"),
    JackpotRatesModel(cardName: "6", rate: "10-10"),
    JackpotRatesModel(cardName: "5", rate: "10-1500"),
    JackpotRatesModel(cardName: "4", rate: "10-3000"),
    JackpotRatesModel(cardName: "3", rate: "10-7000"),
    JackpotRatesModel(cardName: "2", rate: "10-7000"),
    JackpotRatesModel(cardName: "1", rate: "10-10"),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: jackpotRatesModelList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final jackpotRatesModel = jackpotRatesModelList[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(jackpotRatesModel.cardName),
            Text(jackpotRatesModel.rate)
          ],
        );
      },
    );
  }
}

class JackpotRatesModel {
  final cardName;
  final rate;
  JackpotRatesModel({required this.cardName, required this.rate});
}
