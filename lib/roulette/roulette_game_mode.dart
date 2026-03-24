import 'package:sm_project/roulette/double_roulette_screen.dart';
import 'package:sm_project/roulette/single_roulette_screen.dart';
import 'package:sm_project/roulette/triple_roulette_screen.dart';
import 'package:sm_project/utils/filecollection.dart';

class RouletteGameMode extends StatelessWidget {
  final String marketId;
  const RouletteGameMode({super.key, required this.marketId});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.2),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleRouletteScreen(
                                marketId: marketId,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/singleroulette.png',
                          width: screenWidth * 0.4,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoubleRouletteScreen(
                                marketId: marketId,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/doubleroulette.png',
                          width: screenWidth * 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TripleRouletteScreen(
                          marketId: marketId,
                        ),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/tripleroulette.png',
                    width: screenWidth * 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
