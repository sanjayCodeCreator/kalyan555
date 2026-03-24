import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/theme.dart';
import '../providers/recent_rounds_provider.dart';

class AviatorButtons extends ConsumerStatefulWidget {
  const AviatorButtons({super.key});

  @override
  ConsumerState<AviatorButtons> createState() => _AviatorButtonsState();
}

class _AviatorButtonsState extends ConsumerState<AviatorButtons> {
  bool showBalance = false;

  // colors
  Color _getColor(String text) {
    final value = double.tryParse(text.replaceAll("x", "")) ?? 0;
    if (value < 2) {
      return AppColors.aviatorSeventhColor;
    } else if (value < 10) {
      return AppColors.aviatorEighthColor;
    } else {
      return AppColors.aviatorNinthColor;
    }
  }

  // container for showing the multiplied amount
  Widget _chip(String text, BuildContext context) {
    final color = _getColor(text);
    return Container(
      height: 32,
      width: 55,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: Theme.of(context).textTheme.aviatorbodySmallPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentRoundsAsync = ref.watch(recentRoundsProvider);

    return recentRoundsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (rounds) {
        final crashedRounds = rounds
            .where((round) => round.crashAt != null && round.endedAt != null)
            .toList();
        final multipliers =
            crashedRounds.take(16).map((round) => "${round.crashAt}x").toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // first row → 4 chips + button
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                for (int i = 0; i < 4 && i < multipliers.length; i++)
                  Expanded(child: _chip(multipliers[i], context)),
                // Button for showing Balance history of the multplier
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => showBalance = !showBalance),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.aviatorTenthColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(
                            color: AppColors.aviatorEleventhColor),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      minimumSize: const Size(55, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          FontAwesomeIcons.clock,
                          size: 16,
                          color: AppColors.aviatorTertiaryColor,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          showBalance
                              ? FontAwesomeIcons.angleUp
                              : FontAwesomeIcons.angleDown,
                          size: 16,
                          color: AppColors.aviatorTertiaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            //  second row → wrap chips in multiple lines
            if (showBalance)
              Wrap(
                runSpacing: 8,
                children: [
                  for (int i = 4; i < multipliers.length; i++)
                    _chip(multipliers[i], context),
                ],
              ),
          ],
        );
      },
    );
  }
}
