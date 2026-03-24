import 'package:sm_project/utils/filecollection.dart';

class PinSetSuccessful extends StatelessWidget {
  const PinSetSuccessful({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 0, 30, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(successCreatePinLogo),
              const SizedBox(height: 20),
              const Text('Pin Changed!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  )),
              const SizedBox(height: 10),
              const Text("Your pin has been changed successfully.",
                  style: TextStyle(color: Color(0xff9E9E9E))),
              const SizedBox(height: 35),
              buttonSizedBox(
                  color: whiteBackgroundColor,
                  text: 'Back to Login',
                  textColor: whiteBackgroundColor,
                  onTap: () {
                    context.pushReplacementNamed(RouteNames.logInScreen);
                  }),
            ]),
      )),
    );
  }
}
