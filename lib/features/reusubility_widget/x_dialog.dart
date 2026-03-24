import 'package:sm_project/utils/filecollection.dart';

void xdialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback? onPressed,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          titlePadding: EdgeInsets.zero,
          title: Container(
            decoration: const BoxDecoration(
              color: whiteBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/successclick.gif',
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
            ),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: darkBlue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: InkWell(
                  onTap: onPressed,
                  child: const Text(
                    "Okay",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: buttonForegroundColor),
                  ),
                ),
              ),
            ),
            // Center(
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.only(),
            //     ),
            //     onPressed: onPressed,
            //     child: const Text("Okay"),
            //   ),
            // )
          ],
        ),
      );
    },
  );
}
