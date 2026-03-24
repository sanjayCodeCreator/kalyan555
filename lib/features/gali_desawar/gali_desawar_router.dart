import 'package:go_router/go_router.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_screen.dart';

class GaliDesawarPath {
  static const galidesawar = "/gali-desawar";
}

final List<RouteBase> galiDesawarRouter = [
  GoRoute(
    path: GaliDesawarPath.galidesawar,
    name: GaliDesawarPath.galidesawar,
    builder: (context, state) {
      return const GaliDesawarScreen();
    },
  ),
];
