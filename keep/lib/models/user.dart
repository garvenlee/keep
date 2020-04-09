class User {
  String _email;
  String _password;
  String _username;
  String _apiKey;
  String _userPic;
  User(this._email, this._password, this._username, this._apiKey, this._userPic);

  User.map(dynamic obj) {
    this._email = obj["email"];
    this._password = obj["password"] ?? "hey, you don't know";
    this._username = obj["username"];
    this._apiKey = obj["api_key"] ?? "You don't know";
    this._userPic = obj["user_pic"];
  }

  String get email => _email;
  String get password => _password;
  String get apiKey => _apiKey;
  String get username => _username;
  String get userPic => _userPic;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = _email;
    map["password"] = _password;
    map["username"] = _username;
    map["api_key"] = _apiKey;
    map["user_pic"] = _userPic;
    return map;
  }
}