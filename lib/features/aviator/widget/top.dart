import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'custom_tab_bar.dart';
import 'day_widget.dart';
import 'month_widget.dart';
import 'year_widget.dart';

class Top extends StatefulWidget {
  const Top({super.key});

  @override
  State<Top> createState() => _TopState();
}

class _TopState extends State<Top> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.aviatorTertiaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.aviatorFifteenthColor, width: 1),
      ),
      child: Column(
        children: [
          CustomTabBar(
            tabs: ['Day', 'Month', 'Year'],
            backgroundColor: AppColors.aviatorTwentiethColor,
            borderRadius: 52,
            borderWidth: 1,
            borderColor: AppColors.aviatorThirtySixColor,
            selectedTabColor: AppColors.aviatorThirtyFiveColor,
            unselectedTextColor: AppColors.aviatorSixthColor,
            tabViews: [DayWidget(), MonthWidget(), YearWidget()],
          ),
        ],
      ),
    );
  }
}
