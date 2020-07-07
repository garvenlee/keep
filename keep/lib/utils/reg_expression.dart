// form validate
final RegExp emailReg =
    new RegExp(r'^[A-Za-z0-9]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$');
final RegExp codeReg = new RegExp(r'[0-9]{6}');
final RegExp urlRegExp = new RegExp(
    r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
final RegExp groupNumReg = new RegExp('[0-9]{6,10}');
final RegExp phoneNumReg = new RegExp('[0-9]{11}');

String judgeEmail(String val) {
  if (val.isEmpty) return "email cannot be empty!";
  return !emailReg.hasMatch(val) ? "Please check the email's format" : null;
}

String judgePwd(String val) {
  if (val.isEmpty) {
    return "password cannot be empty!";
  } else if (val.length < 8) {
    return "must be at least 8 characters!";
  } else if (val.length > 15) {
    return "must be at most 15 characters!";
  } else {
    return null;
  }
}

String judgeConfirmPwd(String val, String cmpString) {
  if (val.isEmpty) {
    return "password cannot be empty!";
  } else if (val.length < 8) {
    return "must be at least 8 characters!";
  } else if (val.length > 15) {
    return "must be at most 15 characters!";
  } else if (val != cmpString) {
    return "two password is not the same.";
  } else {
    return null;
  }
}

String judgeUsername(String val) {
  return val.isEmpty ? "username cannot be empty!" : null;
}

String judgeCode(String val) {
  if (val.isEmpty) return "code cannot be empty!";
  if (!(val.length == 6)) {
    return "length must be 6";
  } else {
    return !codeReg.hasMatch(val) ? "cannot contain character in code!" : null;
  }
}

String judgeGroupNumber(String val) {
  if (val.isEmpty) return "number cannot be empty!";
  if (val.length < 6 || val.length > 10)
    return "number length must be between 6 and 10.";
  else
    return !groupNumReg.hasMatch(val)
        ? "cannot contain character in number!"
        : null;
}

String judgePhoneNumber(String val) {
  if (val.isEmpty) return "number cannot be empty!";
  if (val.length != 11) return "number length must be 11";
  return !phoneNumReg.hasMatch(val) ? "Please check the format." : null;
}

bool judgeUrl(String text) {
  return urlRegExp.hasMatch(text);
}
