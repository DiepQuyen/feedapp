import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../screens/feed_detail_screen.dart';
import '../dummy_data.dart';

class PostItem extends StatefulWidget {
  final Post post;

  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  late bool isLiked;
  late bool isBookmarked;
  late int bookmarksCount;

  @override
  void initState() {
    super.initState();
    isLiked = false;
    isBookmarked = false;
    bookmarksCount = 0;
    _loadLikeAndBookmarkState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLikeAndBookmarkState();
  }

  Future<void> _loadLikeAndBookmarkState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLiked = prefs.getBool('like_${widget.post.id}') ?? false;
      isBookmarked = prefs.getBool('bookmark_${widget.post.id}') ?? false;
      bookmarksCount = prefs.getInt('bookmark_count_${widget.post.id}') ?? 0;
    });
  }

  Future<void> _toggleLike() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedIsLiked = !isLiked;

    // Update dummyPosts first
    final postIndex = dummyPosts.indexWhere((p) => p.id == widget.post.id);
    if (postIndex != -1) {
      final updatedLikes = dummyPosts[postIndex].likes + (updatedIsLiked ? 1 : -1);
      dummyPosts[postIndex] = Post(
        id: widget.post.id,
        userName: widget.post.userName,
        userAvatar: widget.post.userAvatar,
        timeAgo: widget.post.timeAgo,
        location: widget.post.location,
        content: widget.post.content,
        images: widget.post.images,
        price: widget.post.price,
        likes: updatedLikes,
        comments: dummyPosts[postIndex].commentList.length,
        commentList: List.from(dummyPosts[postIndex].commentList),
      );
    }

    // Then update SharedPreferences and state
    await prefs.setBool('like_${widget.post.id}', updatedIsLiked);
    setState(() {
      isLiked = updatedIsLiked;
    });
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedIsBookmarked = !isBookmarked;
    final updatedBookmarksCount = bookmarksCount + (updatedIsBookmarked ? 1 : -1);

    await prefs.setBool('bookmark_${widget.post.id}', updatedIsBookmarked);
    await prefs.setInt('bookmark_count_${widget.post.id}', updatedBookmarksCount);

    setState(() {
      isBookmarked = updatedIsBookmarked;
      bookmarksCount = updatedBookmarksCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = dummyPosts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => FeedDetailScreen(post: post),
          ),
        ).then((_) {
          setState(() {
            _loadLikeAndBookmarkState();
          });
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(post.userAvatar),
            ),
            title: Text(post.userName),
            subtitle: Text('${post.timeAgo} - Tại ${post.location}'),
            trailing: Icon(Icons.more_horiz),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text.rich(
              TextSpan(
                text: post.content,
                style: TextStyle(fontSize: 15),
                children: [
                  TextSpan(
                    text: ' Xem thêm',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                post.price,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: post.images.length,
              itemBuilder: (ctx, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: Image.network(
                    post.images[index],
                    fit: BoxFit.cover,
                    width: 300,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: _toggleLike,
                ),
                SizedBox(width: 4),
                Text('${post.likes} Thích'),
                SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline),
                SizedBox(width: 4),
                Text('${post.commentList.length} Bình luận'),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.orange : null,
                  ),
                  onPressed: _toggleBookmark,
                ),
                SizedBox(width: 4),
                Text('$bookmarksCount'),
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}