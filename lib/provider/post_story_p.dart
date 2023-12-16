
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:submission_intermediate/data/enum/state.dart';
import 'package:submission_intermediate/data/models/post_story_m.dart';
import 'package:submission_intermediate/data/remote/api_service.dart';

class PostStoryProvider extends ChangeNotifier{
   final ApiService apiService;

  PostStoryProvider(this.apiService);

  ResultState? _state;
  ResultState? get state => _state;

  String _message = "";
  String get message => _message;



Future<dynamic> addStory(PostStoryRequest story) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final detailStoryResult = await apiService.postStory(story);

      if (detailStoryResult.error == true) {
        _state = ResultState.error;

        _message = detailStoryResult.message ?? "Error when uploading!";
      } else {
        _state = ResultState.hasData;

        _message = detailStoryResult.message ?? "Success upload story!";

        
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