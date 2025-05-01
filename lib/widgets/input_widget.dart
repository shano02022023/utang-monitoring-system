import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputWidget extends StatelessWidget {
  const InputWidget({
    super.key,
    required this.hintText,
    required this.controller,
    required this.isRequired,
    this.validator, // Optional validator parameter
    this.readOnly = false,
    this.isText = true,
    this.onChanged, // Add readOnly parameter, default to false
  });

  final String hintText;
  final TextEditingController controller;
  final bool isRequired;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final bool readOnly;
  final bool isText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        keyboardType: isText ? TextInputType.text : TextInputType.number,
        controller: controller,
        validator: validator,
        onChanged: onChanged, // Use the passed validator
        readOnly: readOnly, // Make the field read-only if true
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          label: RichText(
            text: TextSpan(
              text: hintText,
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.black),
              children: <TextSpan>[
                if (isRequired)
                  TextSpan(
                    text: '*',
                    style: GoogleFonts.poppins(color: Colors.red, fontSize: 18),
                  ),
              ],
            ),
          ),
          labelStyle: GoogleFonts.poppins(fontSize: 18),
        ),
      ),
    );
  }
}