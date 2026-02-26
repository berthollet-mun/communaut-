import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final bool isRequired;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextStyle? style; // ✅ Ajout du paramètre style

  const CustomFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.isRequired = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.style, // ✅ Ajout du paramètre
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: style, // ✅ Application du style au TextFormField
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixPressed)
            : null,
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
