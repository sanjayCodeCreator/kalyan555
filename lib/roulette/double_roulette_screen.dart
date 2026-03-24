import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/roulette/roulette_api_service.dart';
import 'package:sm_project/utils/filecollection.dart';

class DoubleRouletteScreen extends ConsumerStatefulWidget {
  final String marketId;
  const DoubleRouletteScreen({super.key, required this.marketId});

  @override
  ConsumerState<DoubleRouletteScreen> createState() =>
      _DoubleRouletteScreenState();
}

class _DoubleRouletteScreenState extends ConsumerState<DoubleRouletteScreen> {
  final Map<String, TextEditingController> _amountControllers = {};
  final RouletteApiService _apiService = RouletteApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each number
    final List<String> numbers = [];

    // Add 00-09
    for (int i = 0; i <= 9; i++) {
      String number = i.toString().padLeft(2, '0');
      numbers.add(number);
      _amountControllers[number] = TextEditingController();
    }

    // Add 10-99
    for (int tens = 1; tens <= 9; tens++) {
      for (int ones = 0; ones <= 9; ones++) {
        String number = '$tens$ones';
        numbers.add(number);
        _amountControllers[number] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _placeBets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> bets = [];

      await ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();

      // Collect all bets with amounts
      for (var entry in _amountControllers.entries) {
        if (entry.value.text.isNotEmpty &&
            int.tryParse(entry.value.text) != null) {
          final int amount = int.parse(entry.value.text);
          if (amount > 0) {
            // For double digits, split the digits
            final String digit1 = entry.key[0];
            final String digit2 = entry.key[1];

            bets.add({
              "user_id": ref
                      .watch(getParticularPlayerNotifierProvider)
                      .value
                      ?.getParticularPlayerModel
                      ?.data
                      ?.sId ??
                  "",
              "tag": "roulette",
              "digit_1": digit1,
              "digit_2": digit2,
              "digit_3": "-",
              "points": amount,
              "game_mode": "double-digit",
              "market_id": widget.marketId,
            });
          }
        }
      }

      if (bets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Please enter at least one bet amount')),
        );
        return;
      }

      final result = await _apiService.createBets(bets: bets);

      if (result != null && result['status'] == 'success') {
        ref
            .read(homeNotifierProvider.notifier)
            .getParticularPlayerModel(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  "Bet placed successfully!",
                  style: TextStyle(color: Colors.white),
                )),
          );
        }

        // Clear all the controllers
        for (var controller in _amountControllers.values) {
          controller.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red,
                content: Text(result?['message'] ?? 'Failed to place bets')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate numbers in the pattern 00-09, 11-19, 21-29, etc.
    final List<String> numbers = [];

    // Add 00-09
    for (int i = 0; i <= 9; i++) {
      numbers.add(i.toString().padLeft(2, '0'));
    }

    // Add 10-99
    for (int tens = 1; tens <= 9; tens++) {
      for (int ones = 0; ones <= 9; ones++) {
        numbers.add('$tens$ones');
      }
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/roulettebg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Text(
                  'Double',
                  style: GoogleFonts.pacifico(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 6,
                              crossAxisSpacing: 6,
                              childAspectRatio: 2.5,
                            ),
                            padding: const EdgeInsets.all(8),
                            itemCount: numbers.length,
                            itemBuilder: (context, index) {
                              return _buildNumberButton(numbers[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _isLoading ? null : _placeBets,
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/roulettebidplace.png',
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                        if (_isLoading)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFD53367),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              height: double.infinity,
              child: Center(
                child: TextField(
                  controller: _amountControllers[number],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
