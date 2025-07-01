import 'package:flutter/material.dart';
import 'package:pint_mobile/models/utilizador.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userToken;

  bool get isLoggedIn => _isLoggedIn;
  String? get userToken => _userToken;

  void login(String token, Utilizador utilizador) {
    _isLoggedIn = true;
    _userToken = token;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userToken = null;
    notifyListeners();
  }
}