import 'package:sm_project/features/gali_desawar/game_button_component.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:sm_project/utils/realtime_timer.dart';

class GaliMarketSelectedScreen extends StatelessWidget {
  final GaliDeswarGameData? gameData;
  final String? tag;

  const GaliMarketSelectedScreen({super.key, this.gameData, this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Text(
          gameData?.name ?? "",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: buttonForegroundColor,
          ),
        ),
        actions: const [
          TimerComponent(
            color: Colors.white,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // SizedBox(height: 0),
              GameButtonComponent(
                gameData: gameData,
                tag: tag ?? "",
              ),
              const SizedBox(height: 14),
              // OpenPlayGameComponent(),
              // JantriGame(),
              // CrossGameComponent(),
            ],
          ),
        ),
      ),
    );
  }
}
