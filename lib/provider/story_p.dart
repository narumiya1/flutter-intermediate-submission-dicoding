import 'dart:io';

import 'package:flutter/material.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/stories_m.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';

class ListStoryProvider extends ChangeNotifier {
  final ApiService apiService;

  ListStoryProvider(this.apiService) {
    getAllStories();
  }
  ResultState? _state;
  ResultState? get state => _state;

  String _message = "";
  String get message => _message;

  final List<Story> _stories = [];
  List<Story> get stories => _stories;

  Future<dynamic> getAllStories() async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final storiesResult = await apiService.getAllStories();

      if (storiesResult.listStory?.isNotEmpty == true) {
        _state = ResultState.hasData;
        _stories.clear();
        _stories.addAll(storiesResult.listStory ?? List.empty());

        _message = storiesResult.message ?? "Get Stories Success!";
      } else {
        _state = ResultState.noData;

        _message = storiesResult.message ?? "Get Stories Failed";
      }
    } on SocketException {
      _state = ResultState.error;

      _message = "Error: No Internet Connection";
    } catch (e) {
      _state = ResultState.error;

      _message = "Error: $e";
    } finally {
      notifyListeners();
    }
  }
}
