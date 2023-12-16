import 'dart:convert';

import 'package:submission_intermediate/data/models/base_response.dart';
import 'package:submission_intermediate/data/models/detail_story_m.dart';
import 'package:submission_intermediate/data/models/login_m.dart';
import 'package:submission_intermediate/data/models/login_request_m.dart';
import 'package:http/http.dart' as http;
import 'package:submission_intermediate/data/models/post_story_m.dart';
import 'package:submission_intermediate/data/models/register_m.dart';
import 'package:submission_intermediate/data/models/stories_m.dart';
import 'package:submission_intermediate/data/pref/token.dart';

class ApiService {
  static const String _baseUrl = "https://story-api.dicoding.dev/v1";
  static const Duration timeLimt = Duration(seconds: 10);
  static final Uri _loginEndpoint = Uri.parse("$_baseUrl/login");
  static final Uri _registerEndpoint = Uri.parse("$_baseUrl/register");
  static final Uri _storiesUrl = Uri.parse("$_baseUrl/stories");
  Uri _detailStoryUrl(String id) => Uri.parse("$_baseUrl/stories/$id");

  Future<LoginM> doLogin(LoginRequest loginRequest) async {
    final response = await http
        .post(_loginEndpoint, body: loginRequest.toJson())
        .timeout(timeLimt);

    var login = LoginM.fromJson(json.decode(response.body));

    if (_isResponseSuccess(response.statusCode)) {
      return login;
    } else {
      throw Exception("${response.statusCode} - ${login.message}");
    }
  }

  Future<Stories> getAllStories() async {
    var tokenPref = Token();
    var token = await tokenPref.getToken();

    final response = await http.get(_storiesUrl, headers: {
      'Authorization': 'Bearer $token',
    }).timeout(timeLimt);
    var stories = Stories.fromJson(json.decode(response.body));
    if (_isResponseSuccess(response.statusCode)) {
      return stories;
    } else {
      throw Exception("${response.statusCode} - ${stories.message}");
    }
  }

  Future<BaseResponse> postStory(PostStoryRequest postStoryRequest) async {
    var tokenPref = Token();
    var token = await tokenPref.getToken();

    final request = http.MultipartRequest('POST', _storiesUrl);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['description'] = postStoryRequest.description;
 request.files.add(http.MultipartFile(
      'photo',
      postStoryRequest.photo.readAsBytes().asStream(),
      postStoryRequest.photo.lengthSync(),
      filename: postStoryRequest.photo.path.split('/').last,
    ));
    if (postStoryRequest.lat != null) {
      request.fields['lat'] = postStoryRequest.lat.toString();
      request.fields['lon'] = postStoryRequest.lon.toString();
    }
    final response = await request.send().timeout(timeLimt);
  if (_isResponseSuccess(response.statusCode)) {
      String responseBody = await response.stream.bytesToString();
      return BaseResponse.fromJson(json.decode(responseBody));
    } else {
      throw Exception("${response.statusCode} - Error when upload story");
    }

  }
  
  Future<dynamic> doRegister(RegisterRequest request) async {
    final response = await http
        .post(_registerEndpoint, body: request.toJson())
        .timeout(timeLimt);

    var baseResponse = BaseResponse.fromJson(json.decode(response.body));

    if (_isResponseSuccess(response.statusCode)) {
      return baseResponse;
    } else {
      throw Exception("${response.statusCode} - ${baseResponse.message}");
    }
  }
  Future<DetailStory> getDetailStory(String id) async {
    var tokenPref = Token();
    var token = await tokenPref.getToken();

    final response = await http.get(_detailStoryUrl(id), headers: {
      'Authorization': 'Bearer $token',
    }).timeout(timeLimt);

    var detailStory = DetailStory.fromJson(json.decode(response.body));

    if (_isResponseSuccess(response.statusCode)) {
      return detailStory;
    } else {
      throw Exception("${response.statusCode} - ${detailStory.message}");
    }
  }

  _isResponseSuccess(int statusCode) => (statusCode >= 200 && statusCode < 300);
}
