import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool autoValidate;
  final bool enabled;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;

  final void Function(String)? onChanged;
  final FocusNode? focusNode;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.controller,
    this.validator,
    this.autoValidate = false,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
      autovalidateMode: autoValidate
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      textAlign: textAlign,
      inputFormatters: inputFormatters,
      cursorColor: AppColors.textTertiaryColor,
      style: GoogleFonts.roboto(
        color: AppColors.textformfieldSecondaryTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        suffixIcon: suffix,
        prefixIcon: prefix,
        hintText: hintText,
        hintStyle: GoogleFonts.roboto(
          // vasil changed color
          color: AppColors.authInputTextColor,
          fontSize: 14,
          // fontWeight: FontWeight.w500,
        ),
        filled: true,
        // vasil changed color
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(52),
          borderSide: BorderSide(
            color:
                // vasil changed color
                AppColors.borderAuthTextField,
            width: 1,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(52),
          borderSide: BorderSide(color: AppColors.borderThirdColor, width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(52),
          borderSide: BorderSide(
            color: AppColors.textformfieldActiveBorderColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(52),
          borderSide: BorderSide(
            color: AppColors.textformfieldErrorBorderColor,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(52),
          borderSide: BorderSide(
            color: AppColors.textformfieldErrorBorderColor,
            width: 2,
          ),
        ),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),
    );
  }
}
