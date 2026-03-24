import 'package:sm_project/utils/filecollection.dart';

class Information extends StatelessWidget {
  const Information({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const AppBarWidget(title: 'Information'),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.all(20),
            child: const Text(
                'Welcome to Kalyan Satta online Matka Play App. \n\nDownload Our Application from Google Play Store or from Official Website. \n\nRegister with your Mobile Number, Email ID, User Name, our Platform. \n\nSelect the Game type, Select your Favourite number and start to play game. \n\nGet a chance to WIn 10 Lac points \n\nRules and Regulations \nMinimum Deposit 100 Rs.\nMinimum Withdrawal 1000 Rs.\nDeposits karne se pehle Admin se Contact Jarur kare'),
          ),
        ]),
      )),
    );
  }
}
