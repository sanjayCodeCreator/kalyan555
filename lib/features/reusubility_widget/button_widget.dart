import 'package:sm_project/utils/filecollection.dart';

// Without Icon
buttonSizedBox(
    {required Color color,
    required String text,
    required Color textColor,
    Color? backgroundColor,
    required Function onTap,
    double? width}) {
  return SizedBox(
      width: width ?? double.infinity,
      height: 50,
      child: ElevatedButton(
          onPressed: onTap as void Function()?,
          style: ElevatedButton.styleFrom(
              backgroundColor: appColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: backgroundColor ?? appColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: appColor, offset: Offset(-1, 1), blurRadius: 5)
                ]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const Icon(Icons.security),
                // const SizedBox(
                //   width: 10,
                // ),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )));
}

// With Button Icon
buttonWithIconSizedBox(
    Color color, IconData icon, String text, Function onTap) {
  return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
          onPressed: onTap as void Function()?,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 10),
              Text(text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          )));
}
