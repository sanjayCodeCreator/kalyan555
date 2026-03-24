import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stylized number input field with validation
class NumberInputField extends StatelessWidget {
  final TextEditingController controller;
  final int minValue;
  final int maxValue;
  final String? errorText;
  final VoidCallback onSubmitted;
  final bool enabled;

  const NumberInputField({
    super.key,
    required this.controller,
    required this.minValue,
    required this.maxValue,
    this.errorText,
    required this.onSubmitted,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = errorText != null;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (hasError ? Colors.red : colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
                (hasError ? Colors.red : colorScheme.secondary).withValues(
                  alpha: 0.05,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasError
                  ? Colors.red.withValues(alpha: 0.5)
                  : colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (hasError ? Colors.red : colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: hasError ? Colors.red : colorScheme.onSurface,
              letterSpacing: 4,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: InputDecoration(
              hintText: '$minValue-$maxValue',
              hintStyle: TextStyle(
                fontSize: 32,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
            ),
            onSubmitted: (_) => onSubmitted(),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
