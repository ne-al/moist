import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autoFocus;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final Function(String)? onChanged;
  final bool readOnly;
  const SearchTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.autoFocus = false,
    this.onSubmitted,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: onTap,
      controller: controller,
      focusNode: focusNode,
      autofocus: autoFocus,
      readOnly: readOnly,
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
