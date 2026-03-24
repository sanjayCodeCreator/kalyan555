import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class RouletteRatesScreen extends HookConsumerWidget {
  const RouletteRatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      ref.read(getSettingNotifierProvider.notifier).getSettingModel();
      return;
    }, []);

    final getSettingModel = ref.watch(getSettingNotifierProvider);
    final getRoulette =
        getSettingModel.value?.getSettingModel?.data?.rates?.roulette;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appColor.withOpacity(0.8),
              backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDynamicRates(getRoulette),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: colorWhite),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Roulette Rates',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the appbar
        ],
      ),
    );
  }

  Widget _buildDynamicRates(Roulette? roulette) {
    if (roulette == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(appColor),
            ),
            SizedBox(height: 20),
            Text(
              'Loading rates...',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildRateCard(
          title: 'Single Digit',
          value:
              '${roulette.singleDigit1 ?? ''} ka ${roulette.singleDigit2 ?? ''}',
          iconData: Icons.looks_one,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildRateCard(
          title: 'Double Digit',
          value:
              '${roulette.doubleDigit1 ?? ''} ka ${roulette.doubleDigit2 ?? ''}',
          iconData: Icons.looks_two,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildRateCard(
          title: 'Triple Digit',
          value:
              '${roulette.tripleDigit1 ?? ''} ka ${roulette.tripleDigit2 ?? ''}',
          iconData: Icons.looks_3,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRateCard({
    required String title,
    required String value,
    required IconData iconData,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, val, child) {
        return Transform.scale(
          scale: val,
          child: Opacity(
            opacity: val,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(iconData, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
