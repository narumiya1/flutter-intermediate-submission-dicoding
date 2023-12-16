
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/detail_story_m.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';

class DetailStoryProvider extends ChangeNotifier{

  final ApiService apiService;
  final String id ;

 DetailStoryProvider(this.apiService, this.id) {
    getDetailStory(id);
  }
  ResultState? _state;
  ResultState? get state => _state;

  Story _story = Story();
  Story get story => _story;

  String _message = "";
  String get message => _message;

   Future<dynamic> getDetailStory(String id) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final detailStoryResult = await apiService.getDetailStory(id);

      if (detailStoryResult.story != null) {
        _state = ResultState.hasData;

        _story = detailStoryResult.story ?? Story();

        _message = detailStoryResult.message ?? "Get Detail Story Success!";
      } else {
        _state = ResultState.noData;

        _message = detailStoryResult.message ?? "Get Detail Story Failed!";
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