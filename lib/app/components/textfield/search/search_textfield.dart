import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool autoFocus;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final Function(String)? onChanged;
  const SearchTextField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    this.autoFocus = false,
    this.onSubmitted,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      controller: controller,
      focusNode: focusNode,
      autofocus: autoFocus,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade800.withOpacity(0.3),
      ),
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
