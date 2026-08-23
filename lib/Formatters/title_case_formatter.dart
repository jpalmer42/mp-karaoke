import 'package:flutter/services.dart';

class TitleCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String formattedText = _toTitleCase(newValue.text);

    return TextEditingValue(
      text: formattedText,
      selection: newValue.selection,
    );
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;

    // Capitalizes the first letter of each word separated by spaces
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          if (word[0] == r'\') return word.substring(1);
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
