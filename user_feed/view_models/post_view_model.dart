import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:sportsfam_apk/news_feed/models/news_error.dart';
import 'package:sportsfam_apk/user_feed/repo/user_feed_cache.dart';

import '../models/post_model.dart';
import '../repo/post_service.dart';

class PostViewModel extends ChangeNotifier {
  bool _isLiked = false;
  bool _isLoading = false;
  int _likeCount = 0;
  int _commentCount = 0;
  Post? postModel;
  String? _currentUserId;
  Future<Post>? originalPostModel;
  Uint8List? _image;
  CommonError? _error;

  // getters
  bool get isLiked => _isLiked;

  bool get isLoading => _isLoading;

  Uint8List? get image => _image;

  Post? get post => postModel;

  Future<Post>? get originalPost => originalPostModel;

  int get likeCount => _likeCount;

  int get commentCount => _commentCount;

  CommonError? get error => _error;

  String? get currentUser => _currentUserId;

  //Constructor
  PostViewModel(this.postModel, this._currentUserId) {
    _likeCount = postModel!.likeCount ?? 0;
    _commentCount = postModel!.commentCount ?? 0;
    initializeData();
  }

  initializeData() async {
    setIsLoading(true);
    await checkIfAlreadyLiked();
    await getImageFromLocal();
    setIsLoading(false);
  }

  //setters
  setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  setImage(Uint8List image) {
    _image = image;
  }

  setIsLiked() {
    _isLiked = !_isLiked;
    print("Is Liked: $_isLiked");
    notifyListeners();
  }

  setOriginalPostModel(Post post) {
    originalPostModel = Future.value(post);
    notifyListeners();
  }

  setPostModel(Post post) {
    print("Setting post model. . . . ");
    postModel = post;
    _likeCount = postModel!.likeCount!;
    _commentCount = postModel!.commentCount!;
  }

  setLike() {
    print("Is Like: $_isLiked");
    print("Like Count: $_likeCount");
    if (_isLiked) {
      _isLiked = false;
      _likeCount = _likeCount > 0 ? _likeCount - 1 : 0;
      print("Like Count after click: $_likeCount");
    } else {
      _isLiked = true;
      _likeCount = _likeCount + 1;
      print("Like Count after click: $_likeCount");
    }
    notifyListeners();
  }

  setCommentCount(int count) {
    _commentCount = count;
    notifyListeners();
  }

  setCommonError(CommonError error) {
    _error = error;
  }

  setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  /* Methods
  *  1. getImageFromLocal
  *  2. getOriginalPost
  *  3. checkIfAlreadyLiked
  *  4. setLike
  *  5. onLikePressed
  * */
  getImageFromLocal() async {
    print("Getting from local. . . . ");
    final imageBytes =
        await UserFeedCache.getImagesByPostId(postModel!.postId!);
    print("Got Image: $imageBytes");
    if (imageBytes != null) setImage(imageBytes);
  }

  // getOriginalPost() async {
  //   print("Getting original post. . . . ");
  //
  //   final response =
  //       await UserFeedService.getPostById(postModel!.originalPostId!);
  //   if (response is Success) {
  //     setOriginalPostModel(response.response as Post);
  //   } else if (response is Failure) {
  //     CommonError error =
  //         CommonError(code: response.code!, message: response.errorResponse);
  //     setCommonError(error);
  //   }
  // }

  onLikePressed() async {
    if (_isLiked) {
      setLike();
      await PostService.unlikePost(postModel!.postId!, currentUser!);
    } else {
      setLike();
      await PostService.likePost(postModel!.postId!, currentUser!);
    }
  }

  checkIfAlreadyLiked() async {
    final response =
        await PostService.checkIfLiked(postModel!.postId!, currentUser!);
    if (response) {
      setIsLiked();
    }
  }
}
