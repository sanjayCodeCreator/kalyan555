import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/roulette/roulette_api_service.dart';
import 'package:sm_project/utils/filecollection.dart';

class SingleRouletteScreen extends ConsumerStatefulWidget {
  final String marketId;
  const SingleRouletteScreen({super.key, required this.marketId});

  @override
  ConsumerState<SingleRouletteScreen> createState() =>
      _SingleRouletteScreenState();
}

class _SingleRouletteScreenState extends ConsumerState<SingleRouletteScreen> {
  final RouletteApiService _apiService = RouletteApiService();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers for each number
    for (int i = 0; i <= 9; i++) {
      _controllers[i.toString()] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _placeBets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> bets = [];

      await ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();

      // Add all non-empty bets to the list
      for (int i = 0; i <= 9; i++) {
        final number = i.toString();
        final controller = _controllers[number];

        if (controller != null &&
            controller.text.isNotEmpty &&
            int.tryParse(controller.text) != null &&
            int.parse(controller.text) > 0) {
          bets.add({
            "user_id": ref
                    .watch(getParticularPlayerNotifierProvider)
                    .value
                    ?.getParticularPlayerModel
                    ?.data
                    ?.sId ??
                "",
            "tag": "roulette",
            "digit_1": number,
            "points": int.parse(controller.text),
            "game_mode": "single-digit",
            "market_id": widget.marketId
          });
        }
      }

      if (bets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text("Please enter at least one bet amount")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await _apiService.createBets(bets: bets);

      if (result != null && result['status'] == 'success') {
        // Clear all controllers after successful bet
        for (var controller in _controllers.values) {
          controller.clear();
        }

        ref
            .read(homeNotifierProvider.notifier)
            .getParticularPlayerModel(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Bet placed successfully!",
                style: TextStyle(color: Colors.white),
              )),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text(result?['message'] ?? "Failed to place bet")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Text(
                  'Single',
                  style: GoogleFonts.pacifico(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 60),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 5),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            padding: const EdgeInsets.all(10),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.2,
                            children: List.generate(10, (index) {
                              final number = index == 9 ? 0 : index + 1;
                              return _buildNumberButton(number.toString());
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _isLoading ? null : _placeBets,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/roulettebidplace.png',
                            fit: BoxFit.fill,
                            width: double.infinity,
                          ),
                        ),
                        if (_isLoading)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
            offset: const Offset(0, 2),
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
                  controller: _controllers[number],
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
