import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sportsfam_apk/utils/constants.dart';

import '../../news_feed/repo/api_status.dart';
import '../models/post_model.dart';

class UserFeedService {
  /* This may be a common method so make sure it goes into a separate directory
     which may be named as common or utils */

  static Future<String> getCurrentUserId() async {
    final user = await Amplify.Auth.getCurrentUser();
    return user.username;
  }

  static Future<Object> getFeedPosts() async {
    try {
      String userId = await getCurrentUserId();
      final url = Uri.parse("$USER_FEED_SERVICE$userId/feed");
      final response = await http.get(url);
      if (response.statusCode == OK) {
        Map<String, dynamic> data = jsonDecode(response.body);
        final postData = data["posts"] as List;
        List<Post> posts = postData.map((post) => Post.fromJson(post)).toList();
        print("posts: $posts");
        return Success(code: OK, response: posts);
      }
      return Failure(
          code: INVALID_RESPONSE, errorResponse: jsonDecode(response.body));
    } on HttpException {
      return Failure(
          code: NO_INTERNET, errorResponse: "No Internet Connection");
    } on FormatException {
      return Failure(code: INVALID_FORMAT, errorResponse: "Invalid Format");
    } catch (e) {
      print(e);
      return Failure(code: UNKNOWN_ERROR, errorResponse: "Unknown Error");
    }
  }

  static Future<Post?> getPostById(String postId) async {
    try {
      final url = Uri.parse("$USER_POST_SERVICE$postId");
      final response = await http.get(url);
      if (response.statusCode == OK) {
        final data = jsonDecode(response.body);
        final post = data["data"];
        return Post.fromJson(post);
      }
    } catch (e) {
      print(e);
      return null;
    }
  }
}
