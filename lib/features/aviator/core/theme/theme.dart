import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

ThemeData theme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.aviatorSixteenthColor),
  //! scaffold
  scaffoldBackgroundColor: AppColors.bgScaffoldAuthScreen,

  //!appbar
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.bgAppbarAuthScreen,
    iconTheme: IconThemeData(color: AppColors.authFifthColor, size: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
  ),

  //! icon
  iconTheme: const IconThemeData(color: AppColors.authPrimaryColor),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(AppColors.authFifthColor),
    ),
  ),
);

//!text
extension CustomTextStyle on TextTheme {
  /*
  !Use it for reference for Naming
   static const displayLarge = TextStyle(fontSize: 57, fontWeight: FontWeight.bold);
  static const displayMedium = TextStyle(fontSize: 45, fontWeight: FontWeight.w600);
  static const displaySmall = TextStyle(fontSize: 36, fontWeight: FontWeight.w600);

  static const headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w600);
  static const headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.w500);
  static const headlineSmall = TextStyle(fontSize: 24, fontWeight: FontWeight.w500);

   // Titles
  static const titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const titleMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const titleSmall = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  // Body
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

  // Special
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  */

  //!_________________________________________Authentication______________________________________

  TextStyle get authHeadlineMedium => GoogleFonts.roboto(
        color: AppColors.authFifthColor,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );
  TextStyle get authTitleLarge => GoogleFonts.roboto(
        color: AppColors.authFifthColor,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      );

  TextStyle get authBodyLargePrimary => GoogleFonts.roboto(
        color: AppColors.authInputTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  TextStyle get authBodyLargeSecondary => GoogleFonts.roboto(
        color: AppColors.authFifthColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      );

  TextStyle get authBodyLargeTertiary => GoogleFonts.roboto(
        color: AppColors.authSixthColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get authBodyLargeFourth => GoogleFonts.roboto(
        color: AppColors.authTertiaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  // vasil changed the color
  TextStyle get authBodyMediumPrimary => GoogleFonts.roboto(
        color: AppColors.authSeventhColor,
        // color: AppColors.authFourthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get authBodyMediumSecondary => GoogleFonts.roboto(
        color: AppColors.authTertiaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get authBodyMediumThird => GoogleFonts.roboto(
        //color: Colors.white,
        color: AppColors.authFifthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get authBodyMediumFourth => GoogleFonts.roboto(
        color: AppColors.authSixthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  //!________________________________Aviator_____________________________________

  TextStyle get aviatorDisplayLarge => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      );
  TextStyle get aviatorDisplayLargeSecond => GoogleFonts.roboto(
        color: AppColors.aviatorTwentyEighthColor,
        fontSize: 40,
        fontWeight: FontWeight.w600,
      );

  TextStyle get aviatorHeadlineSmall => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );
  TextStyle get aviatorHeadlineSmallSecond => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  // TextStyle get aviatorHeadlineSmallSecond => GoogleFonts.roboto(
  //   color: AppColors.aviatorTwentyEighthColor,
  //   fontSize: 24,
  //   fontWeight: FontWeight.w600,
  // );

  TextStyle get aviatorBodyTitleMdeium => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );

  TextStyle get aviatorBodyLargePrimary => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get aviatorBodyLargeSecondary => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );

  TextStyle get aviatorBodyLargeThird => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get aviatorBodyMediumPrimary => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get aviatorBodyMediumPrimaryBold => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );

  TextStyle get aviatorBodyMediumSecondary => GoogleFonts.roboto(
        color: AppColors.aviatorThirtySevenColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get aviatorBodyMediumThird => GoogleFonts.roboto(
        color: AppColors.aviatorThirtyFiveColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get aviatorBodyMediumFourth => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get aviatorBodyMediumFifth => GoogleFonts.roboto(
        color: AppColors.aviatorFourtyColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get aviatorBodyMediumFourthBold => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );

  TextStyle get aviatorbodySmallPrimary => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
  TextStyle get aviatorbodySmallPrimaryBold => GoogleFonts.roboto(
        color: AppColors.aviatorTertiaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

  TextStyle get aviatorbodySmallSecondary => GoogleFonts.roboto(
        color: AppColors.aviatorTwentyFourthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  TextStyle get aviatorbodySmallThird => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 10,
        fontWeight: FontWeight.w400,
      );
  TextStyle get aviatorbodySmallThirdBold => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );

  TextStyle get aviatorbodySmallFourth => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
  TextStyle get aviatorbodySmallFourthBold => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );
  TextStyle get aviatorbodySmallFifth => GoogleFonts.roboto(
        color: AppColors.aviatorSixthColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      );

  //!________________________________Home_____________________________________

  TextStyle get homeSmallPrimary => GoogleFonts.roboto(
        color: AppColors.textPrimaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
  TextStyle get homeSmallPrimaryBold => GoogleFonts.roboto(
        color: AppColors.textPrimaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

  //!________________________________Wallet_____________________________________

  TextStyle get walletDisplaySmallPrimary => GoogleFonts.roboto(
        color: AppColors.walletEighthColor,
        fontSize: 34,
        fontWeight: FontWeight.w500,
      );
  TextStyle get walletTitleMediumPrimary => GoogleFonts.roboto(
        color: AppColors.walletEighthColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );
  TextStyle get walletBodyMediumPrimary => GoogleFonts.roboto(
        color: AppColors.walletEighthColor,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );
  TextStyle get walletBodyMediumSecondary => GoogleFonts.roboto(
        color: AppColors.walletSeventeenthColor,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );
  TextStyle get walletSmallPrimary => GoogleFonts.roboto(
        color: AppColors.walletSeventeenthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get walletSmallSecondary => GoogleFonts.roboto(
        color: AppColors.walletSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get walletBodySmallPrimary => GoogleFonts.roboto(
        color: AppColors.walletTwelfthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
  TextStyle get walletBodySmallSecondary => GoogleFonts.roboto(
        color: AppColors.walletEighteenthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  TextStyle get walletBodySmallThird => GoogleFonts.roboto(
        color: AppColors.walletEighthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  //!________________________________Offers_____________________________________
  //!________________________________Payment___________________________________

  TextStyle get paymentTitleMediumPrimary => GoogleFonts.roboto(
        color: AppColors.paymentFifteenthColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );

  TextStyle get paymentBodyLargePrimary => GoogleFonts.roboto(
        color: AppColors.textPrimaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get paymentBodyLargeSecondary => GoogleFonts.roboto(
        color: AppColors.paymentEighthColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get paymentBodyLargeThird => GoogleFonts.roboto(
        color: AppColors.paymentSixthColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  TextStyle get paymentSmallPrimary => GoogleFonts.roboto(
        color: AppColors.paymentPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get paymentSmallSecondary => GoogleFonts.roboto(
        color: AppColors.textPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get paymentSmallThird => GoogleFonts.roboto(
        color: AppColors.paymentFourthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get paymentSmallFourth => GoogleFonts.roboto(
        color: AppColors.paymentTwelfthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get paymentSmallFifth => GoogleFonts.roboto(
        color: AppColors.paymentThirteenthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get paymentBodySmallPrimary => GoogleFonts.roboto(
        color: AppColors.paymentTenthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
  TextStyle get paymentBodySmallSecondary => GoogleFonts.roboto(
        color: AppColors.paymentSeventeenthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  TextStyle get paymentBodySmallThird => GoogleFonts.roboto(
        color: AppColors.textPrimaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  //!________________________________Crash___________________________________
  TextStyle get crashHeadlineSmall => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      );

  TextStyle get crashBodyTitleMdeium => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );
  TextStyle get crashBodyTitleSmall => GoogleFonts.roboto(
        color: AppColors.crashThirtySecondColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  TextStyle get crashBodyTitleSmallSecondary => GoogleFonts.roboto(
        color: AppColors.crashSecondaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  TextStyle get crashBodyTitleSmallThird => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  TextStyle get crashBodyLargeSecondary => GoogleFonts.roboto(
        color: AppColors.crashSecondaryColor,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      );

  TextStyle get crashBodyMediumPrimary => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get crashBodyMediumSecondary => GoogleFonts.roboto(
        color: AppColors.crashThirteenthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get crashBodyMediumThird => GoogleFonts.roboto(
        color: AppColors.crashThirtyFivethColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get crashBodyMediumFourth => GoogleFonts.roboto(
        color: AppColors.crashSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get crashBodyMediumFourthBold => GoogleFonts.roboto(
        color: AppColors.crashSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
  TextStyle get crashBodyMediumFifth => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );

  TextStyle get crashbodySmallPrimary => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
  TextStyle get crashbodySmallPrimaryBold => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

  TextStyle get crashBodySmallSecondary => GoogleFonts.roboto(
        color: AppColors.crashThirteenthColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );
  TextStyle get crashBodySmallThird => GoogleFonts.roboto(
        color: AppColors.crashSecondaryColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );
  TextStyle get crashbodySmallThird => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      );
  TextStyle get crashbodySmallFourth => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      );
  TextStyle get crashbodySmallFifth => GoogleFonts.roboto(
        color: AppColors.crashSecondaryColor,
        fontSize: 10,
        fontWeight: FontWeight.w400,
      );
  TextStyle get crashbodySmallFiftBold => GoogleFonts.roboto(
        color: AppColors.crashSecondaryColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      );
  //!________________________________SpinToWin___________________________________

  TextStyle get spinHeadlineSmall => GoogleFonts.roboto(
        color: AppColors.spinToWinSecondaryColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  TextStyle get spinBodyTitleMdeium => GoogleFonts.roboto(
        color: AppColors.spinToWinSecondaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );

  TextStyle get spinBodyTitleSmall => GoogleFonts.roboto(
        color: AppColors.spinToWinSecondaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  TextStyle get spinBodyTitleSmallSecondary => GoogleFonts.roboto(
        color: AppColors.spinToWinSeventhColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
  TextStyle get spinBodyTitleSmallTertiary => GoogleFonts.roboto(
        color: AppColors.spinToWinTwelfthColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  TextStyle get spinBodyMediumPrimary => GoogleFonts.inter(
        color: AppColors.spinToWinSecondaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get spinBodyMediumSecondary => GoogleFonts.roboto(
        color: AppColors.crashPrimaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

  TextStyle get spinBodyMediumThird => GoogleFonts.roboto(
        color: AppColors.spinToWinThirTeenthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get spinBodyMediumFourth => GoogleFonts.roboto(
        color: AppColors.spinToWinSixteenthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );
  TextStyle get spinBodyMediumFifth => GoogleFonts.roboto(
        color: AppColors.spinToWinTwelfthColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      );

  TextStyle get spinbodySmallPrimary => GoogleFonts.roboto(
        color: AppColors.spinToWinSecondaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  TextStyle get spinbodySmallSecondary => GoogleFonts.roboto(
        color: AppColors.spinToWinSixteenthColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  /*
  !Use it for reference for Naming
   static const displayLarge = TextStyle(fontSize: 57, fontWeight: FontWeight.bold);
  static const displayMedium = TextStyle(fontSize: 45, fontWeight: FontWeight.w600);
  static const displaySmall = TextStyle(fontSize: 36, fontWeight: FontWeight.w600);

  static const headlineLarge = TextStyle(fontSize: 32, fontWeight: FontWeight.w600);
  static const headlineMedium = TextStyle(fontSize: 28, fontWeight: FontWeight.w500);
  static const headlineSmall = TextStyle(fontSize: 24, fontWeight: FontWeight.w500);

   // Titles
  static const titleLarge = TextStyle(fontSize: 22, fontWeight: FontWeight.bold);
  static const titleMedium = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const titleSmall = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  // Body
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.normal);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

  // Special
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static const caption = TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  */
}
