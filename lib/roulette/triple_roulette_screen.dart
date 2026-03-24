import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/roulette/roulette_api_service.dart';
import 'package:sm_project/utils/filecollection.dart';

class TripleRouletteScreen extends ConsumerStatefulWidget {
  final String marketId;
  const TripleRouletteScreen({super.key, required this.marketId});

  @override
  ConsumerState<TripleRouletteScreen> createState() =>
      _TripleRouletteScreenState();
}

class _TripleRouletteScreenState extends ConsumerState<TripleRouletteScreen> {
  @override
  Widget build(BuildContext context) {
    // Generate numbers from 000 to 999
    final List<String> numbers = [];
    final Map<String, TextEditingController> controllers = {};

    // Create controllers for each number
    for (int i = 0; i <= 999; i++) {
      String num = i.toString().padLeft(3, '0');
      numbers.add(num);
      controllers[num] = TextEditingController();
    }

    final RouletteApiService apiService = RouletteApiService();

    // Function to place bids
    Future<void> placeBids() async {
      await ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();
      List<Map<String, dynamic>> bets = [];

      // Collect all non-empty bets
      controllers.forEach((number, controller) {
        if (controller.text.isNotEmpty &&
            int.tryParse(controller.text) != null) {
          final points = int.parse(controller.text);
          if (points > 0) {
            // Split the number into individual digits
            final digit1 = number[0];
            final digit2 = number[1];
            final digit3 = number[2];

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
              "digit_3": digit3,
              "points": points,
              "game_mode": "triple-digit",
              "market_id": widget.marketId,
            });
          }
        }
      });

      if (bets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Please enter at least one bet amount')),
        );
        return;
      }

      // Call the API to place bets
      final result = await apiService.createBets(bets: bets);

      if (result != null && result['status'] == 'success') {
        ref
            .read(homeNotifierProvider.notifier)
            .getParticularPlayerModel(context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  "Bet placed successfully!",
                  style: TextStyle(color: Colors.white),
                )),
          );
        }
        // Clear all controllers
        controllers.forEach((key, controller) {
          controller.clear();
        });
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: Colors.red,
                content: Text(result?['message'] ?? 'Failed to place bets')),
          );
        }
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Text(
                  'Triple',
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
                      borderRadius: BorderRadius.circular(20),
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
                              childAspectRatio: 2.2,
                            ),
                            padding: const EdgeInsets.all(8),
                            itemCount: numbers.length,
                            itemBuilder: (context, index) {
                              return _buildNumberButton(
                                  numbers[index], controllers[numbers[index]]!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // Handle bid place action
                    placeBids();
                  },
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/roulettebidplace.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number, TextEditingController controller) {
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
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: double.infinity,
              child: Center(
                child: TextField(
                  controller: controller,
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
