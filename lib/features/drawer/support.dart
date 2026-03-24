import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class Support extends HookConsumerWidget {
  const Support({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refRead = ref.read(getParticularPlayerNotifierProvider.notifier);
    useEffect(() {
      refRead.getParticularPlayerModel(context: context);
      return;
    }, []);
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: appColor,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 13, 0, 0),
            child: InkWell(
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
          ),
          title: const Text(
            "Support",
            style: TextStyle(color: whiteBackgroundColor, fontSize: 18),
          ),
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Consumer(builder: (context, ref, child) {
                final refWatch = ref.watch(homeNotifierProvider);
                final refRead = ref.read(homeNotifierProvider.notifier);
                return Column(children: [
                  InkWell(
                    onTap: () {
                      refRead.callUs(refWatch
                              .value?.getParticularPlayerModel?.data?.mpin ??
                          '');
                    },
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                        decoration: BoxDecoration(
                            color: whiteBackgroundColor,
                            border: Border.all(color: appColor),
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(children: [
                          Row(children: [
                            const Icon(Icons.phone, color: textColor),
                            const SizedBox(width: 20),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Call Us',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor)),
                                  const SizedBox(height: 5),
                                  Text(
                                      refWatch.value?.getParticularPlayerModel
                                              ?.data?.mpin ??
                                          '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor))
                                ])
                          ])
                        ])),
                  ),
                  const SizedBox(height: 20),
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                      decoration: BoxDecoration(
                          color: whiteBackgroundColor,
                          border: Border.all(color: appColor),
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                        children: [
                          Row(children: [
                            Image.asset('assets/images/WhatsApp_icon 1.png',
                                width: 35),
                            const SizedBox(width: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Whatsapp Us',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor)),
                                  const SizedBox(height: 5),
                                  Text(
                                      refWatch.value?.getParticularPlayerModel
                                              ?.data?.mpin ??
                                          "",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor))
                                ])
                          ])
                        ],
                      )),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      ref.read(homeNotifierProvider.notifier).launchTelegram(
                          refWatch.value?.getParticularPlayerModel?.data
                                  ?.mpin ??
                              '');
                    },
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                        decoration: BoxDecoration(
                            color: whiteBackgroundColor,
                            border: Border.all(color: appColor),
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(children: [
                              const Icon(Icons.telegram, size: 30),
                              const SizedBox(width: 10),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Telegram Us',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textColor)),
                                    const SizedBox(height: 5),
                                    Text(
                                        refWatch.value?.getParticularPlayerModel
                                                ?.data?.mpin ??
                                            '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: textColor))
                                  ])
                            ])
                          ],
                        )),
                  )
                ]);
              }))),
    );
  }
}
