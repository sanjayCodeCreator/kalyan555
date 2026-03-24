import 'package:sm_project/utils/filecollection.dart';

class StarlineResultHistoryScreen extends StatelessWidget {
  const StarlineResultHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text('Starline Result History',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'Coming soon',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}


