class User {
  final String email;
  final String password;
  final String houseName;

  User({required this.email, required this.password, required this.houseName});
}

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  User? _user;

  User? get user => _user;

  void signUp(String email, String password, String houseName) {
    _user = User(email: email, password: password, houseName: houseName);
  }

  bool login(String email, String password) {
    if (_user != null && _user!.email == email && _user!.password == password) {
      return true;
    }
    return false;
  }
}
