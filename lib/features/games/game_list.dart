import 'package:sm_project/features/games/default_game_list.dart';
import 'package:sm_project/utils/filecollection.dart';

List<Map> gamelist(BuildContext context, WidgetRef ref, String tag,
        String marketId, String marketName) =>
    [
      ...defaultGamelist(context, ref, tag, marketId, marketName),
    ];
