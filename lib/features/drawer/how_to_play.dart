import 'package:sm_project/utils/filecollection.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        backgroundColor: darkBlue,
        iconTheme: const IconThemeData(color: buttonForegroundColor),
        title: const Text(
          "How to Play",
          style: TextStyle(
            color: buttonForegroundColor,
            fontSize: 18,
          ),
        ),
      ),
      body: const SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  "Download app from playstore. Fill necessary detail and click on register. OTP will get on your mobile no. You will approve by admin in 2 min. You allow to all services. here is recommended video"),
            ),
          ],
        ),
      ),
    );
  }
}
