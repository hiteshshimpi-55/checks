import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportsfam_apk/providers/user_data_provider.dart';
import 'package:sportsfam_apk/user_feed/view_models/user_feed_view_model.dart';
import 'package:sportsfam_apk/utils/navigation_utils.dart';
import 'package:sportsfam_apk/utils/text_utility.dart';

import '../../utils/constants.dart';
import '../../views/repost_screen.dart';
import '../models/post_model.dart';
import '../view_models/post_view_model.dart';

class MyPostWidget extends StatelessWidget {
  final Post post;

  const MyPostWidget({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String userId =
        Provider.of<UserDataProvider>(context, listen: false).userModel!.userId;
    UserFeedViewModel userFeedViewModel =
        Provider.of<UserFeedViewModel>(context, listen: false);

    return ChangeNotifierProvider(
        create: (context) => PostViewModel(post, userId),
        child: _ui(context, userFeedViewModel, post, userId));
  }

  Widget _ui(BuildContext context, UserFeedViewModel userFeedViewModel,
      Post post, String userId) {
    return Consumer<PostViewModel>(builder: (context, postViewModel, child) {
      return Card(
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content
          children: [
            ListTile(
              leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      "$USER_PROFILE_IMAGE${post.userId}/profile-picture.jpeg")),
              title: Text(post.userId!),
            ),
            if (post.postText != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(TextUtils.utf8convert(post!.postText!)),
              ),
            if (post!.imageId != null)
              SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: postViewModel.image != null
                      ? Image.memory(postViewModel.image!)
                      : CachedNetworkImage(
                          imageUrl:
                              '$USER_POST_IMAGE_SERVICE${post!.postId}/images/${post!.imageId}.${post!.fileExtension}',
                          placeholder: (context, url) =>
                              Center(child: const CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: postViewModel.onLikePressed,
                  icon: Icon(
                    postViewModel.isLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: postViewModel.isLiked ? Colors.red : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    int commentCount =
                        await openCommentScreen(context, post.postId!, userId);
                    postViewModel.setCommentCount(commentCount);
                  },
                  icon: const Icon(Icons.comment),
                ),
                IconButton(
                  onPressed: () async {
                    Post? originalPost;
                    if (post.originalPostId != null) {
                      originalPost = await postViewModel.originalPost;
                    } else {
                      originalPost = post;
                    }
                    Post newPost = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RepostScreen(
                          postModel: originalPost!,
                          userId: userId,
                        ),
                      ),
                    );
                    if (newPost != null) {
                      print(
                          "Got New Post: ${newPost.postId}, ${newPost.likeCount}");
                      userFeedViewModel.addPost(newPost);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text("${postViewModel.likeCount ?? 0} likes"),
                const SizedBox(
                  width: 10,
                ),
                Text("${postViewModel.commentCount ?? 0} comments"),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    });
  }
}
