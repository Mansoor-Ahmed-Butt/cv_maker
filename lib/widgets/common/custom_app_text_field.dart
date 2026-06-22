import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';

class CustomAppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isRequired;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputAction? textInputAction;

  const CustomAppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.isRequired = true,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.obscureText = false,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.appBlue.withValues(alpha: 0.15),
                        AppColors.appPink.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppColors.appBlue),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: AppStyle.style15w600(color: AppColors.titleColor),
              ),
            ],
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          obscureText: obscureText,
          textInputAction: textInputAction,
          style: AppStyle.style15w500(color: AppColors.titleColor),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            hintStyle: AppStyle.style14w400(
              color: AppColors.bodyText.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: AppColors.surfaceLight,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: maxLines > 1 ? 18 : 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.borderColor,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.appBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.danger, width: 2.5),
            ),
          ),
          validator: (value) {
            if (validator != null) return validator!(value);
            if (isRequired && (value == null || value.isEmpty)) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
