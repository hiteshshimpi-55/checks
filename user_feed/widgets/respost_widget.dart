import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sportsfam_apk/user_feed/repo/user_feed_service.dart';
import 'package:sportsfam_apk/utils/text_utility.dart';

import '../../utils/constants.dart';
import '../models/post_model.dart';

class MyRepostWidget extends StatefulWidget {
  final Post post;

  const MyRepostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<MyRepostWidget> createState() => _MyRepostWidgetState();
}

class _MyRepostWidgetState extends State<MyRepostWidget>
    with AutomaticKeepAliveClientMixin {
  Post? originalPost;

  @override
  void initState() {
    getOriginalPost();
    super.initState();
  }

  getOriginalPostFromLocal() async {
    Post? post = await UserFeedService.getPostById(widget.post.originalPostId!);
    if (post == null) {
      getOriginalPost();
    } else
      setState(() {
        originalPost = post;
      });
  }

  getOriginalPost() async {
    Post? post = await UserFeedService.getPostById(widget.post.originalPostId!);
    setState(() {
      originalPost = post;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (originalPost == null) {
      return Center(child: CircularProgressIndicator());
    } else {
      return _ui(context, widget.post, originalPost!);
    }
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

Widget _ui(BuildContext context, Post currentPost, Post originalPost) {
  return SizedBox(
    height: originalPost.imageId != null ? 400 : 150,
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        color: Colors.grey[200],
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                  "$USER_PROFILE_IMAGE${originalPost.userId}/profile-picture.jpeg",
                ),
              ),
              title: Text(originalPost.userId!),
            ),
            if (originalPost.postText != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(TextUtils.utf8convert(originalPost.postText!)),
              ),
            if (originalPost.imageId != null)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: CachedNetworkImage(
                    imageUrl:
                        '$USER_POST_IMAGE_SERVICE${originalPost.postId}/images/${originalPost.imageId}.${originalPost.fileExtension}',
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    placeholder: (context, url) =>
                        Center(child: const CircularProgressIndicator())),
              ),
          ],
        ),
      ),
    ),
  );
}
