import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sportsfam_apk/utils/constants.dart';

import '../models/post_model.dart';

class UserFeedCache {
  static storePostImage(List<Post> list) async {
    print("Store Post Image was called. . . . . ");
    if (list.length > 15) list = list.sublist(0, 15);
    for (var post in list) {
      if (post.imageId != null) {
        Uri url = Uri.parse(
            "$USER_POST_IMAGE_SERVICE${post.postId}/images/${post
                .imageId}.${post.fileExtension}");
        try {
          var response = await http.get(url);
          if (response.statusCode == 200) {
            final image = response.bodyBytes;
            print("Image : $image");
            final compressedImage = await FlutterImageCompress.compressWithList(
              image,
              quality:
              60, // Adjust the quality as per your requirement (0 - 100)
            );
            final listOfImages = [compressedImage];
            UserFeedCache.storeImage({
              "postId": post.postId,
              "images": listOfImages,
            });
          } else {
            print("Failed to fetch image with URL: ${url}");
          }
        } catch (e) {
          print("Failed to fetch image with URL: ${e.toString()}");
        }
      }
    }
  }

  static storePostsMetaData(List<Post> list) async {
    final List<Map<String, dynamic>> jsonList =
    list.map((post) => post.toJson()).toList();
    final jsonString = json.encode(jsonList);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/posts/posts.json');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    await file.writeAsString(jsonString);
  }

  static Future<List<Post>> getPosts() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/posts/posts.json');

    if (!await file.exists()) {
      return []; // Return an empty list if the file doesn't exist
    }

    final jsonString = await file.readAsString();
    final jsonList = json.decode(jsonString) as List<dynamic>;

    final List<Post> posts =
    jsonList.map((json) => Post.fromJson(json)).toList();
    return posts;
  }

  static storeImage(Map<String, dynamic> item) async {
    final postId = item["postId"];
    final List<List<int>> images = item["images"];

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    String targetDirectory = "$path/posts/images/$postId";
    await Directory(targetDirectory).create(recursive: true);

    for (int i = 0; i < images.length; ++i) {
      String imageName = "$i.jpg";
      String imagePath = "$targetDirectory/$imageName";
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(images[i]);
    }
  }

  static Future<Uint8List?> getImagesByPostId(String postId) async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String path = appDocumentsDir.path;

    String targetDir = '$path/posts/images/$postId';
    List<Uint8List> imageList = [];

    try {
      final Directory directory = Directory(targetDir);
      final List<FileSystemEntity> files = directory.listSync();
      for (final file in files) {
        if (file is File) {
          List<int> bytes = await file.readAsBytes();
          Uint8List imageBytes = Uint8List.fromList(bytes);
          imageList.add(imageBytes);
        }
      }
    } catch (e) {
      print("Error: $e");
    }

    return imageList[0];
  }

  static Future<Post?> getPostById(String postId) async {
    final List<Post> posts = await getPosts();
    for (final post in posts) {
      if (post.postId == postId) {
        return post;
      }
    }
    return null;
  }

  static clearTheLocalStorage() async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String path = appDocumentsDir.path;
    String targetDir = '$path/posts';
    Directory directory = Directory(targetDir);

    if (await directory.exists()) {
      directory.deleteSync(recursive: true);
    }
  }
}
