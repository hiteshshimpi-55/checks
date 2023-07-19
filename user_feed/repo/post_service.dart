import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sportsfam_apk/utils/constants.dart';

import '../../model/comment_model.dart';

class PostService {
  static Future<bool> likePost(String postId, String userId) async {
    bool result = false;
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/like");
    try {
      final body = json.encode({"userId": userId});
      final response = await http.post(url, body: body);
      print(response);
      if (response.statusCode == OK) result = true;
    } catch (err) {
      print(err);
    }

    return result;
  }

  static Future<bool> unlikePost(String postId, String userId) async {
    bool result = false;
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/like");
    try {
      final body = json.encode({"userId": userId});
      final response = await http.delete(url, body: body);
      print(response);
      if (response.statusCode == OK) result = true;
    } catch (error) {
      print(error);
    }
    return result;
  }

  static Future<int> getLikeCount(String postId) async {
    int likeCount = 0;
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/like");
    try {
      final response = await http.get(url);
      final body = json.decode(response.body);
      likeCount = body['likeCount'];
    } catch (err) {
      print(" LikeCountMethod : $err");
    }
    return likeCount;
  }

  static Future<bool> checkIfLiked(String postId, String userId) async {
    bool result = false;
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/like/$userId");
    try {
      final response = await http.get(url);
      Map<String, dynamic> data = jsonDecode(response.body);
      result = data["likeExists"];
    } catch (err) {
      print(err);
    }
    return result;
  }

  static Future<List<String>> getPostLikes(String postId) async {
    List<String> likes = [];
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/likes");
    try {
      final response = await http.get(url);
      Map<String, dynamic> data = jsonDecode(response.body);
      likes = List<String>.from(data["users"]);
    } catch (err) {
      print(err);
    }
    return likes;
  }

  static Future<List<CommentModel>> getAllComments(String postId) async {
    List<CommentModel> commentList = [];
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/comments");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> comments = jsonDecode(response.body)['comments'];
        commentList =
            comments.map((item) => CommentModel.fromJson(item)).toList();
      }
    } catch (err) {
      print("getAllComments: $err");
    }
    return commentList;
  }

  static Future<bool> addComment(
      String postId, String comment, String userId) async {
    bool result = false;
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/comments");
    final body = jsonEncode({"commentText": comment, "userId": userId});
    try {
      final response = await http.post(url, body: body);
      result = (response.statusCode == 200) ? true : false;
    } catch (err) {
      print(" addCommentPost: $err");
    }

    return result;
  }

  static Future<int> getCommentCount(String postId) async {
    final url = Uri.parse("$ACTIVITY_SERVICE$postId/comments/count");
    int result = 0;
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        result = jsonDecode(response.body)['count'];
      }
    } catch (error) {
      print(error);
    }

    return result;
  }
}
