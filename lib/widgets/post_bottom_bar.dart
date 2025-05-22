import 'package:flutter/material.dart';

class PostBottomBar extends StatelessWidget {
  final int likes;
  final int comments;
  final int bookmarks;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;
  final bool isLiked;

  const PostBottomBar({
    super.key,
    required this.likes,
    required this.comments,
    required this.bookmarks,
    this.onLike,
    this.onComment,
    this.onBookmark,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : null),
          onPressed: onLike,
        ),
        Text('$likes Thích'),
        SizedBox(width: 16),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline),
          onPressed: onComment,
        ),
        Text('$comments Bình luận'),
        Spacer(),
        IconButton(
          icon: Icon(Icons.star_border),
          onPressed: onBookmark,
        ),
        Text('$bookmarks'),
      ],
    );
  }
}