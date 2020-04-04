class User {
  String _email;
  String _password;
  String _username;
  String _apiKey;
  User(this._email, this._password, this._username, this._apiKey);

  User.map(dynamic obj) {
    this._email = obj["email"];
    this._password = obj["password"];
    this._username = obj["username"] ?? "little Cabin";
    this._apiKey = obj["api_key"];
  }

  String get email => _email;
  String get password => _password;
  String get apiKey => _apiKey;
  String get username => _username;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["email"] = _email;
    map["password"] = _password;
    map["username"] = _username;
    map["api_key"] = _apiKey;
    return map;
  }
}