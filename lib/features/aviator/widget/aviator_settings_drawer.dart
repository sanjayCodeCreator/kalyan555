import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/theme.dart';
import '../core/utils/sound_manager.dart';
import '../providers/aviator_music_provider.dart';

/// Shows a settings drawer positioned below a specific widget (like a hamburger icon)
void showAviatorSettingsDrawer({
  required BuildContext context,
  required Offset position,
  required Size size,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Settings',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      // Calculate position: right below the icon
      final top = position.dy + size.height;
      final right =
          MediaQuery.of(context).size.width - position.dx - size.width;

      return Stack(
        children: [
          Positioned(
            top: top,
            right: right,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: AppColors.aviatorThirteenthColor,
                  // color: AppColors.aviatorFourtyThreeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const _SettingsDrawerContent(),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    },
  );
}

/// The content of the settings drawer
class _SettingsDrawerContent extends StatelessWidget {
  const _SettingsDrawerContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.aviatorBodyLargeThird,

                // .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.aviatorTertiaryColor,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 16),
          // Music and Start Sound Toggles
          Consumer(
            builder: (context, ref, child) {
              final isMusicOn = ref.watch(aviatorMusicProvider);
              final isStartSoundOn = ref.watch(aviatorStartSoundProvider);

              return Column(
                children: [
                  // Music Toggle
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        const Icon(
                          Icons.music_note,
                          color: AppColors.aviatorTertiaryColor,
                          size: 16,
                        ),
                        // const SizedBox(width: 8),
                        Text(
                          'Music',
                          style: Theme.of(
                            context,
                          ).textTheme.aviatorBodyMediumPrimaryBold,
                        ),
                      ],
                    ),
                    trailing: Transform.scale(
                      scale: 0.6,
                      child: Switch(
                        inactiveTrackColor: AppColors.aviatorThirteenthColor,
                        inactiveThumbColor: AppColors.aviatorFourtyTwoColor,
                        activeTrackColor: AppColors.aviatorFourtyTwoColor,
                        value: isMusicOn,
                        onChanged: (value) async {
                          ref
                              .read(aviatorMusicProvider.notifier)
                              .setMusic(value);
                          if (value) {
                            await SoundManager.aviatorMusic();
                          } else {
                            await SoundManager.stopAviatorMusic();
                          }
                        },
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 16),
                  // Sound Effects Toggle (controls start sound and flew away sound)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        const Icon(
                          Icons.volume_up,
                          color: AppColors.aviatorTertiaryColor,
                          size: 16,
                        ),
                        // const SizedBox(width: 2),
                        Text(
                          'Sound',
                          style: Theme.of(
                            context,
                          ).textTheme.aviatorBodyMediumPrimaryBold,
                        ),
                      ],
                    ),
                    trailing: Transform.scale(
                      scale: 0.6,
                      child: Switch(
                        inactiveTrackColor: AppColors.aviatorThirteenthColor,
                        inactiveThumbColor: AppColors.aviatorFourtyTwoColor,
                        activeTrackColor: AppColors.aviatorFourtyTwoColor,
                        value: isStartSoundOn,
                        onChanged: (value) {
                          ref
                              .read(aviatorStartSoundProvider.notifier)
                              .setStartSound(value);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
