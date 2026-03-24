import 'package:flutter/services.dart';
import 'package:sm_project/utils/filecollection.dart';

class AppBarDesign2 extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const AppBarDesign2({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            context.pop();
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appBarIconColor,
            ),
            child: const Center(
              child: Icon(
                Icons.arrow_back,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      title: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: appBarIconColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
