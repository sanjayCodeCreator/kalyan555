import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class RatesScreen extends HookConsumerWidget {
  const RatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref.read(getSettingNotifierProvider.notifier).getSettingModel();
      return;
    }, []);
    final getSettingModel = ref.watch(getSettingNotifierProvider);
    final getData = getSettingModel.value?.getSettingModel?.data;
    final mainDisplay = getData?.mainDisplay ?? true;
    final mainRates = getData?.rates?.main;
    final galiDisawarRates = getData?.rates?.galidisawar;

    TextStyle textStyle = const TextStyle(
        fontSize: 16, fontWeight: FontWeight.w600, color: textColor);
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: appColor,
            leading: context.canPop()
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 13, 0, 0),
                    child: InkWell(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: whiteBackgroundColor, width: 0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Padding(
                                  padding: EdgeInsets.fromLTRB(12.0, 10, 7, 10),
                                  child: Icon(Icons.arrow_back_ios,
                                      size: 15, color: whiteBackgroundColor)))
                        ])),
                  )
                : null,
            title: const Text(
              "Rates",
              style: TextStyle(color: whiteBackgroundColor, fontSize: 18),
            ),
            iconTheme: const IconThemeData(color: Colors.black)),
        body: SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
              children: mainDisplay
                  ? [
                      // Main rates when mainDisplay is true
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Single Digit - ${mainRates?.singleDigit1 ?? ''} ka ${mainRates?.singleDigit2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Jodi Digit - ${mainRates?.jodiDigit1 ?? ''} ka ${mainRates?.jodiDigit2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Single Pana - ${mainRates?.singlePanna1 ?? ''} ka ${mainRates?.singlePanna2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Double Pana - ${mainRates?.doublePanna1 ?? ''} ka ${mainRates?.doublePanna2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Triple Pana - ${mainRates?.tripplePanna1 ?? ''} ka ${mainRates?.tripplePanna2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Half Sangam - ${mainRates?.halfSangum1 ?? ''} ka ${mainRates?.halfSangum2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Full Sangam - ${mainRates?.fullSangum1 ?? ''} ka ${mainRates?.fullSangum2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      )
                    ]
                  : [
                      // Gali Disawar rates when mainDisplay is false
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Right Digit - ${galiDisawarRates?.rightDigit1 ?? ''} ka ${galiDisawarRates?.rightDigit2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Left Digit - ${galiDisawarRates?.leftDigit1 ?? ''} ka ${galiDisawarRates?.leftDigit2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE6F5FF),
                            border: Border.all(color: const Color(0xff98CD5C)),
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                            'Jodi Digit - ${galiDisawarRates?.jodiDigit1 ?? ''} ka ${galiDisawarRates?.jodiDigit2 ?? ''}',
                            textAlign: TextAlign.center,
                            style: textStyle),
                      )
                    ]),
        )));
  }
}
