import 'package:sm_project/utils/filecollection.dart';

class AppBackICon extends StatelessWidget {
  const AppBackICon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: InkWell(
            onTap: () {
              context.pop();
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: textColor.withOpacity(0.5), width: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                      padding: EdgeInsets.fromLTRB(10.0, 5, 5, 5),
                      child: Icon(Icons.arrow_back_ios,
                          size: 15, color: Colors.black)))
            ])));
  }
}
