import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String value;
  final TextInputType keyboardType;
  final String label;
  final Icon prefixIcon;
  final ValueChanged<String> onChanged;

  const CustomTextField({
    required this.value,
    required this.keyboardType,
    required this.label,
    required this.prefixIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      initialValue: value,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        hintText: 'Enter your $label',
        prefixIcon: prefixIcon,
        prefixIconColor: Colors.blue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
