import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:sportsfam_apk/user_feed/view_models/user_feed_view_model.dart';
import 'package:sportsfam_apk/user_feed/widgets/post_widget.dart';

import '../../utils/global_colors.dart';
import '../models/post_model.dart';

class MyUserFeedScreen extends StatelessWidget {
  const MyUserFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Feed"),
      ),
      body: Consumer<UserFeedViewModel>(
          builder: (context, userFeedViewModel, child) =>
              _ui(userFeedViewModel)),
    );
  }

  Widget _ui(UserFeedViewModel userFeedViewModel) {
    if (userFeedViewModel.getIsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (userFeedViewModel.error.code != 0) {
      return Center(
        child: Text(userFeedViewModel.error.message.toString()),
      );
    } else {
      return FutureBuilder<List<Post>>(
          future: userFeedViewModel.feedPosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    Text(snapshot.error.toString()),
                    ElevatedButton(
                        onPressed: () {
                          userFeedViewModel.getUserFeed();
                        },
                        child: const Text("Retry"))
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              return LiquidPullToRefresh(
                  onRefresh: userFeedViewModel.getUserFeed,
                  color: GlobalColors.primaryColor,
                  showChildOpacityTransition: false,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = snapshot.data![index];
                      return MyPostWidget(
                        key: ValueKey(snapshot.data![index].postId),
                        post: snapshot.data![index],
                      );
                    },
                  ));
            } else {
              return const Center(
                child: Text("No Posts"),
              );
            }
          });
    }
  }
}
