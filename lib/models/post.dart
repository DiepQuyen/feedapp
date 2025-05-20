// lib/models/post.dart

import 'comment.dart';

class Post {
  final String id;
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String location;
  final String content;
  final List<String> images;
  final String price;
  final int likes;
  final int comments;
  final List<Comment> commentList;

  Post({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.location,
    required this.content,
    required this.images,
    required this.price,
    required this.likes,
    required this.comments,
    required this.commentList,
  });
}
