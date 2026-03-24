import 'package:intl/intl.dart';
import 'package:sm_project/features/gali_desawar/notifier/result_rules_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class GaliDesawarResultRules extends ConsumerStatefulWidget {
  const GaliDesawarResultRules({super.key});

  @override
  ConsumerState<GaliDesawarResultRules> createState() =>
      _GaliDesawarResultRulesState();
}

class _GaliDesawarResultRulesState
    extends ConsumerState<GaliDesawarResultRules> {
  @override
  void initState() {
    ref.read(resultRulesNotifierProvider.notifier).getResultModel('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final refWatch =
        ref.watch(resultRulesNotifierProvider).value?.getSettingModel;

    final refAllMarket =
        ref.watch(resultRulesNotifierProvider).value?.getAllResultModel;

    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  DateTime now = DateTime.now();
                  DateTime yesterday = now.subtract(const Duration(days: 1));

                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(yesterday);

                  ref.read(resultRulesNotifierProvider.notifier).getResultModel(
                      '?tag=galidisawar&from=${formattedDate}T00:00:00.000Z');
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: whiteBackgroundColor,
                      border: Border.all(color: darkBlue),
                    ),
                    child: Text('Yesterday',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkBlue))),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  ref
                      .read(resultRulesNotifierProvider.notifier)
                      .getResultModel('');
                },
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: whiteBackgroundColor,
                      border: Border.all(color: darkBlue),
                    ),
                    child: Text('Today',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkBlue))),
              ),
            ),
            Expanded(
                child: InkWell(
              onTap: () {
                ref
                    .read(resultRulesNotifierProvider.notifier)
                    .selectDate(context, true);
              },
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: whiteBackgroundColor,
                    border: Border.all(color: darkBlue),
                  ),
                  child: Text('Select Date',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkBlue))),
            ))
          ]),
          const SizedBox(height: 20),
          Visibility(
              visible:
                  ref.watch(resultRulesNotifierProvider).value?.isVisible ==
                      true,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: whiteBackgroundColor,
                            border: Border.all(color: darkBlue),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                  '${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "Date" : ref.watch(resultRulesNotifierProvider).value?.fromDate?.day.toString() ?? ""} ${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : ref.watch(resultRulesNotifierProvider).value?.fromDate?.month.toString() ?? ""} ${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : ref.watch(resultRulesNotifierProvider).value?.fromDate?.year.toString() ?? ""}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textColor))
                            ])),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        final String? fromDate = ref
                                    .watch(resultRulesNotifierProvider)
                                    .value
                                    ?.fromDate
                                    ?.day
                                    .toString()
                                    .length ==
                                1
                            ? '0${ref.watch(resultRulesNotifierProvider).value?.fromDate?.day.toString()}'
                            : ref
                                .watch(resultRulesNotifierProvider)
                                .value
                                ?.fromDate
                                ?.day
                                .toString();

                        // Month

                        final String? fromMonth = ref
                                    .watch(resultRulesNotifierProvider)
                                    .value
                                    ?.fromDate
                                    ?.month
                                    .toString()
                                    .length ==
                                1
                            ? '0${ref.watch(resultRulesNotifierProvider).value?.fromDate?.month.toString()}'
                            : ref
                                .watch(resultRulesNotifierProvider)
                                .value
                                ?.fromDate
                                ?.month
                                .toString();

                        ref
                            .read(resultRulesNotifierProvider.notifier)
                            .getResultModel(
                                '?tag=galidisawar&from=${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : ref.watch(resultRulesNotifierProvider).value?.fromDate?.year.toString()}-${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : fromMonth}-${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : fromDate}T00:00:00.000Z');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: darkBlue,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Text('Submit',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 10),
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: refAllMarket?.data?.length ?? 0,
              itemBuilder: (context, index) {
                final refMarketData = refAllMarket?.data?[index];
                return Stack(
                  children: [
                    Image.asset('assets/images/result.png'),
                    Positioned(
                        top: 32,
                        left: 48,
                        child: Text(refMarketData?.marketDetails?.name ?? '',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: Color(0xFFA20B01),
                                fontSize: 14,
                                fontWeight: FontWeight.bold))),
                    Positioned(
                        top: 73,
                        left: 66,
                        child: Text(
                            refMarketData?.marketDetails?.resultTime ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                fontSize: 16))),
                    Positioned(
                        bottom: 18,
                        left: 76,
                        // right: 0,
                        child: Text(
                            '${refMarketData?.marketDetails?.openDigit}${refMarketData?.marketDetails?.closeDigit}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: whiteBackgroundColor,
                                fontSize: 26))),
                  ],
                );
              }),
          const SizedBox(height: 10),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(
                    0xFFA20B01,
                  ),
                  borderRadius:
                      BorderRadius.only(topRight: Radius.circular(40))),
              child: const Text('RULES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: whiteBackgroundColor))),
          Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: whiteBackgroundColor,
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 9.0,
                    ),
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                      'Jodi Rate - ${refWatch?.data?.rates?.galidisawar?.jodiDigit1 ?? ''} ka ${refWatch?.data?.rates?.galidisawar?.jodiDigit2 ?? ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 5),
                  Text(
                      'Harup Andar Rate - ${refWatch?.data?.rates?.galidisawar?.leftDigit1 ?? ''} ka ${refWatch?.data?.rates?.galidisawar?.leftDigit2 ?? ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 5),
                  Text(
                      'Harup Bahar Rate - ${refWatch?.data?.rates?.galidisawar?.rightDigit1 ?? ''} ka ${refWatch?.data?.rates?.galidisawar?.rightDigit2 ?? ''}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 5),
                  Text(
                      'Minimum add money ${refWatch?.data?.deposit?.min ?? 0} INR 24x7 Available',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 5),
                  Text(
                      'Minimum withdrawal money ${refWatch?.data?.withdraw?.min ?? 0} INR 24x7 Available',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 15),
                  RichText(
                      text: const TextSpan(children: [
                    TextSpan(
                        text: 'Jodi Rules - ',
                        style: TextStyle(
                            color: Color(0xFFA20B01),
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(height: 15),
                  RichText(
                      text: const TextSpan(children: [
                    TextSpan(
                        text: 'Harup Rules - ',
                        style: TextStyle(
                            color: Color(0xFFA20B01),
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ])),
                  const SizedBox(height: 20),
                ],
              )),
          const SizedBox(height: 20),
        ]),
      )),
    );
  }
}
