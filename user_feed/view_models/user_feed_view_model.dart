import 'package:flutter/material.dart';
import 'package:sportsfam_apk/news_feed/repo/api_status.dart';
import 'package:sportsfam_apk/user_feed/repo/post_service.dart';

import '../../news_feed/models/news_error.dart';
import '../models/post_model.dart';
import '../repo/user_feed_cache.dart';
import '../repo/user_feed_service.dart';

class UserFeedViewModel with ChangeNotifier {
  bool? isLoading;
  Post? _selectedPost;
  Future<List<Post>> _feedPosts = Future.value([]);
  CommonError _error = CommonError(code: 0, message: "");

  // getters
  bool get getIsLoading => isLoading!;

  Future<List<Post>> get feedPosts => _feedPosts;

  CommonError get error => _error;

  Post? get selectedPost => _selectedPost;

  // setters
  setIsLoading(bool value) {
    print("SetLoading Called: ${value}");
    isLoading = value;
    notifyListeners();
  }

  setFeedPosts(List<Post> value) {
    print("Set Feed Posts Called: ${value.length}");
    _feedPosts = Future.value(value);
    notifyListeners();
  }

  setError(CommonError value) {
    _error = value;
  }

  setSelectedPost(Post value) {
    _selectedPost = value;
    notifyListeners();
  }

  UserFeedViewModel() {
    initializeData();
  }

  initializeData() async {
    setIsLoading(true);
    await getUserFeedFromLocal();
    setIsLoading(false);
  }

  getUserFeedFromLocal() async {
    final response = await UserFeedCache.getPosts();
    if (response.isNotEmpty) {
      setFeedPosts(response);
    } else {
      await getUserFeed();
    }
  }

  Future<void> getUserFeed() async {
    final response = await UserFeedService.getFeedPosts();
    if (response is Success) {
      print("Posts Response: ${response.response}");
      setFeedPosts(response.response as List<Post>);
      setIsLoading(false);
      await storePostsInCache(response.response as List<Post>);
    } else if (response is Failure) {
      print("Failure hai bhai .....${response.errorResponse}");
      setError(
          CommonError(code: response.code!, message: response.errorResponse));
    }
  }

  storePostsInCache(List<Post> posts) async {
    await UserFeedCache.storePostsMetaData(posts);
    await UserFeedCache.storePostImage(posts);
  }

  likePost(String postId, String userId) async {
    final response = await PostService.likePost(postId, userId);
    if (response) {
      print("Like Response: ${response}");
    } else {
      print("Failure hai bhai .....${response}");
    }
  }

  void addPost(Post newPost) async {
    print("Add Post Called");
    List<Post> posts = await _feedPosts;
    print("Post Length: ${posts.length}");
    posts.insert(0, newPost);
    setFeedPosts(posts);
  }
}
