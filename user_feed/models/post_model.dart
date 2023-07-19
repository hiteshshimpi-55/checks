

class Post {
  String? fileExtension;
  String? imageId;
  String? userId;
  DateTime? createTime;
  String? postId;
  String? postText;
  String? originalPostId;
  int? likeCount;
  int? commentCount;

  Post({
    this.fileExtension,
    this.imageId,
    this.userId,
    this.createTime,
    this.postId,
    this.postText,
    this.originalPostId,
    this.likeCount,
    this.commentCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        fileExtension: json["fileExtension"],
        imageId: json["imageId"],
        userId: json["userId"]!,
        createTime: json["createTime"] == null
            ? null
            : DateTime.parse(json["createTime"]),
        postId: json["postId"],
        postText: json["postText"],
        originalPostId: json["originalPostId"],
        likeCount: json["likeCount"],
        commentCount: json["commentCount"],
      );

  Map<String, dynamic> toJson() => {
        "fileExtension": fileExtension,
        "imageId": imageId,
        "userId": userId,
        "createTime": createTime?.toIso8601String(),
        "postId": postId,
        "postText": postText,
        "originalPostId": originalPostId,
        "likeCount": likeCount,
        "commentCount": commentCount,
      };
}
