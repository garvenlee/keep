import 'package:shared_preferences/shared_preferences.dart';

Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<String> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<String> getApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiKey');
  }

  Future<String> getUserPic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userPic');
  }

  // Future<void> _loadUser() async {
  //   Future<String> username = getUsername();
  //   Future<String> email = getEmail();
  //   Future<String> apiKey = getApiKey();
  //   Future<String> userPic = getUserPic();

  //   username.then((val) => setState(() => _username = val));
  //   email.then((val) => setState(() => _email = val));
  //   apiKey.then((val) => setState(() => _apiKey = val));
  //   userPic.then((val) => setState(() => _userPic = val));
  // }
