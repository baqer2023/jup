import 'package:flutter/material.dart';
import 'package:my_app32/app/theme/app_colors.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({
    super.key,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.label,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.prefixIcon,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final TextInputType? keyboardType;

  final int? maxLength;

  final void Function(String text)? onChanged;
  final String? Function(String? text)? validator;
  final Widget? label;
  final String? hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.gray[400]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.gray[400]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.gray[400]!),
        ),
        label: label,
        hintText: hintText,
        counterText: '',
      ),
    );
  }
}
