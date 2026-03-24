import 'package:sm_project/features/card_jackpot/component/card_jackpot_balance_header_component.dart';
import 'package:sm_project/features/card_jackpot/component/jackpot_card_selector_component.dart';
import 'package:sm_project/features/card_jackpot/component/jackpot_grid.dart';
import 'package:sm_project/features/card_jackpot/component/jackpot_history_component.dart';
import 'package:sm_project/features/card_jackpot/component/jackpot_number_selector_component.dart';
import 'package:sm_project/features/card_jackpot/component/jackpot_rate_time_component.dart';
import 'package:sm_project/utils/filecollection.dart';

class CardJackpotScreen extends StatelessWidget {
  const CardJackpotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration:  BoxDecoration(color: darkBlue),
                child: const Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardJackpotBalanceHeader(),
                      ],
                    ),
                    Positioned.fill(
                      bottom: -40,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: JackpotCardSelectorComponent(),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
              height: size.height * 0.55,
              decoration: const BoxDecoration(color: Colors.white),
              child: const SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      JackpotRateTimeComponent(),
                      SizedBox(
                        height: 10,
                      ),
                      JackpotGrid(),
                      SizedBox(
                        height: 10,
                      ),
                      JackpotNumberSelectorComponent(),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      SizedBox(
                        height: 5,
                      ),
                      JackpotHistoryComponent(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
