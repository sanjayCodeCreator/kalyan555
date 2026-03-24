import 'package:sm_project/utils/filecollection.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Image.asset(
        initialScreen,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      ),
      Positioned(
        top: 70,
        // bottom: 30,
        left: 30,
        right: 30,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(appIcon,
                  width: MediaQuery.of(context).size.width * 0.4),
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () {
                context.pushNamed(RouteNames.logInScreen);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: appBarIconColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: whiteBackgroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () {
                context.pushNamed(RouteNames.registerScreen);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: appBarIconColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Register',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: whiteBackgroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    ]));
  }
}
