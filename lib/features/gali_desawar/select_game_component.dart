import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/features/gali_desawar/select_game_notifier.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/colors.dart';

class SelectGameComponent extends StatelessWidget {
  const SelectGameComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final refWatch = ref.watch(selectGameNotifierProvider).value;
      final refRead = ref.read(selectGameNotifierProvider.notifier);
      return DropdownButtonFormField<GaliDeswarGameData>(
        hint: const Text(
          "SELECT GAME",
          style: TextStyle(color: Colors.green, fontSize: 14),
        ),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(),
          isDense: true,
          fillColor: Color(0xffebf7f7),
          filled: true,
        ),
        items: refWatch?.gameList?.data?.map(
          (e) {
            return DropdownMenuItem(
                value: e,
                child: Text(
                  '${e.name.toString()} ${convert24HrTo12Hr(e.closeTime.toString())})',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor),
                ));
          },
        ).toList(),
        onChanged: (value) {
          refRead.updateGameId(value?.sId ?? "");
        },
      );
    });
  }
}
