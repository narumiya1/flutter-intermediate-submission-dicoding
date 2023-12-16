import 'dart:io';

import 'package:flutter/material.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/register_m.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';

class RegisterProvider extends ChangeNotifier {
  final ApiService apiService;

  RegisterProvider(this.apiService);

  ResultState? _registerState;
  ResultState? get registerState => _registerState;

  String _registerMessage = "";
  String get registerMessage => _registerMessage;

  Future<dynamic> register(RegisterRequest registerRequest) async {
    try {
      _registerState = ResultState.loading;
      notifyListeners();

      final registerResult = await apiService.doRegister(registerRequest);
      if (registerResult.error != true) {
        _registerState = ResultState.hasData;
        _registerMessage = registerResult.message ?? "Register Failed";
      } else {
        _registerState = ResultState.noData;
        _registerMessage = registerResult.message ?? "Register Failed";
      }
    } on SocketException {
      _registerState = ResultState.error;

      return _registerMessage = "Error: No Internet Connection!";
    } catch (e) {
      _registerState = ResultState.error;

      _registerMessage = "Error: $e";
    } finally {
      notifyListeners();
    }
  }
}
