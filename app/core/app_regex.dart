class AppRegex {
  static bool checkValidField(String text, RegExp regex) {
    if (text.isNotEmpty) {
      return regex.hasMatch(text);
    }
    return false;
  }

  static final RegExp phoneNumberRegex = RegExp(r'^09[0-9]{9}$');
  static final RegExp passwordPatternRegex = RegExp(r'^\S{6,}$');
}
