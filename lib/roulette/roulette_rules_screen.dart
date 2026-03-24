import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class RouletteRulesScreen extends StatelessWidget {
  const RouletteRulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        foregroundColor: colorWhite,
        title: const Text('Roulette Rules'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final settingData = ref.watch(getSettingNotifierProvider);

          return settingData.when(
            data: (data) {
              final rouletteRules = data.getSettingModel?.data?.rouletteRules;

              return _buildRulesContent(context, rouletteRules);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: appColor),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: appColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load rules',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(getSettingNotifierProvider.notifier)
                          .getSettingModel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      foregroundColor: colorWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRulesContent(BuildContext context, String? rules) {
    if (rules == null || rules.isEmpty) {
      return _buildNoRulesView();
    }

    // Check if the rules are in HTML format
    final isHtml = rules.contains('<') && rules.contains('>');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [appColor, Color(0xFF752F2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.casino,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  'Roulette Game Rules',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please read all rules carefully before playing',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rules content
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: isHtml
                ? Html(data: rules)
                : Text(
                    rules,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
          ),

          const SizedBox(height: 24),

          // Rates section
          _buildRatesSection(context),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNoRulesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.casino_outlined,
            size: 80,
            color: Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No rules available at the moment',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check back later',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final settingData = ref.watch(getSettingNotifierProvider);

        return settingData.when(
          data: (data) {
            final rouletteRates = data.getSettingModel?.data?.rates?.roulette;

            if (rouletteRates == null) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Roulette Game Rates',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildRateItem('Single Digit',
                      '${rouletteRates.singleDigit1 ?? "-"} : ${rouletteRates.singleDigit2 ?? "-"}'),
                  _buildRateItem('Double Digit',
                      '${rouletteRates.doubleDigit1 ?? "-"} : ${rouletteRates.doubleDigit2 ?? "-"}'),
                  _buildRateItem('Triple Digit',
                      '${rouletteRates.tripleDigit1 ?? "-"} : ${rouletteRates.tripleDigit2 ?? "-"}'),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: appColor),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildRateItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.casino,
              color: appColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: appColor,
            ),
          ),
        ],
      ),
    );
  }
}
