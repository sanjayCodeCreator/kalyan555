import 'package:sm_project/utils/filecollection.dart';

class AppBarWidget extends StatelessWidget {
  final String? title;
  const AppBarWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appColor,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          InkWell(
              onTap: () {
                context.pop();
              },
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: whiteBackgroundColor, width: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 5, 5, 5),
                        child: Icon(Icons.arrow_back_ios,
                            size: 15, color: whiteBackgroundColor)))
              ])),
          const Spacer(),
          Text(title ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: whiteBackgroundColor)),
          const Spacer(),
        ],
      ),
    );
  }
}
