class Validator {
  static String validateUserName(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Username can\'t be empty';
    }

    return null;
  }

  static String validateFlatNumber(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Flat number can\'t be empty';
    }

    return null;
  }

  static String validateEmail(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Email can\'t be empty';
    } else if (!value.contains(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))) {
      return 'Enter a correct email address';
    }

    return null;
  }

  static String validatePassword(String value) {
    value = value.trim();

    String compinedReg = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[_!@#\$%\^&\*])(?=.{6,})';
    String smallReg = r'^(?=.*[a-z])';
    String capitalReg = r'^(?=.*[A-Z])';
    String charReg = r'^(?=.*[_!@#\$%\^&\*])';
    String numberReg = r'^(?=.*[0-9])';

    if (value.isEmpty) {
      return 'Password can\'t be empty';
    } else if (!value.contains(RegExp(compinedReg))) {
      String resultError = 'Enter a correct password:';

      if (!value.contains(RegExp(smallReg))) {
        resultError += '\n' + 'Atleat 1 small letter';
      }

      if (!value.contains(RegExp(capitalReg))) {
        resultError += '\n' + 'Atleat 1 capital letter';
      }

      if (!value.contains(RegExp(charReg))) {
        resultError += '\n' + 'Atleat 1 character';
      }

      if (!value.contains(RegExp(numberReg))) {
        resultError += '\n' + 'Atleat 1 number';
      }

      if (value.length < 6) {
        resultError += '\n' + 'Not less than 6 characters';
      }

      return resultError;
    }

    return null;
  }
}
