// lib/models/comment.dart

class Comment {
  final String userName;
  final String userAvatar;
  final String timeAgo;
  final String message;

  Comment({
    required this.userName,
    required this.userAvatar,
    required this.timeAgo,
    required this.message,
  });
}
