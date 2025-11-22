class Validators {
  static bool isValidEmail(String email) {
    //Local validation only
    return email.contains('@') &&
        email.split('@').length == 2 &&
        email.split('@')[1].contains('.');
  }

  static bool isValidPassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    return hasMinLength && hasNumber && hasLetter;
  }

  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  static bool areAllFieldsFilled(List<String> fields) {
    return fields.every((field) => field.trim().isNotEmpty);
  }
}