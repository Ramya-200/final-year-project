import 'dart:math';

import 'package:flutter/foundation.dart';

import '/utils/constants.dart';

String? validateEmail(String? value) {
  const String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  final RegExp regex = RegExp(pattern);
  if (value == null || !regex.hasMatch(value)) {
    return 'Not a valid email.';
  } else {
    return null;
  }
}

String? validatePassword(String? value) {
  //check whether the entered password is more than 8 characters or not
  if (value == null || value.length < 8) {
    return 'Password must be at least 8 characters long.';
  }
  return value.isEmpty ? 'Invalid password' : null;
}

String randomString(int length) {
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  final Random r = Random();
  return String.fromCharCodes(
      Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
}

String? get authRedirectUri {
  if (kIsWeb) {
    return null;
  } else {
    return myAuthRedirectUri;
  }
}
