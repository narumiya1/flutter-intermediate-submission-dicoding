import 'dart:io';

import 'package:flutter/material.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/login_request_m.dart';
import 'package:submission_intermediate/data/pref/token.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';

class LoginProvider extends ChangeNotifier {
  final ApiService apiService;
  final Token token;

  LoginProvider(this.apiService, this.token);

  ResultState? _loginState;
  ResultState? get loginState => _loginState;

  String _loginMessage = "";
  String get loginMessage => _loginMessage;

  Future<dynamic> loginP(LoginRequest loginRequest) async {
    try {
      _loginState = ResultState.loading;
      notifyListeners();

      final loginResult = await apiService.doLogin(loginRequest);
      if (loginResult.error != true) {
        _loginState = ResultState.hasData;
        token.setToken(loginResult.loginResult?.token ?? " ");
        _loginMessage = loginResult.message ?? " Login Sukses ";
      } else {
        _loginState = ResultState.noData;

        _loginMessage = loginResult.message ?? "Login Failed!";
      }
    } on SocketException {
      _loginState = ResultState.error;

      _loginMessage = "Error: No Internet Connection";
    } catch (e) {
      _loginState = ResultState.error;

      _loginMessage = "Error: $e";
    } finally {
      notifyListeners();
    }
  }
}
