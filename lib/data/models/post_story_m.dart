import 'dart:ffi';
import 'dart:io';

class PostStoryRequest {
  String description;
  File photo;
  Float? lat;
  Float? lon;

  PostStoryRequest(
      {required this.description, required this.photo, this.lat, this.lon});
}