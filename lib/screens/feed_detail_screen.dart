import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post.dart';
import '../widgets/comment_item.dart';
import '../models/comment.dart';
import '../dummy_data.dart';

class FeedDetailScreen extends StatefulWidget {
  final Post post;

  const FeedDetailScreen({super.key, required this.post});

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  late bool isLiked;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with default value
    isLiked = false;
    _loadLikeState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLikeState();
  }

  Future<void> _loadLikeState() async {
    final prefs = await SharedPreferences.getInstance();
    // Use the same key format as in PostItem
    setState(() {
      isLiked = prefs.getBool('like_${widget.post.id}') ?? false;
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

  void _addComment() {
    final text = commentController.text.trim();
    if (text.isNotEmpty) {
      final postIndex = dummyPosts.indexWhere((p) => p.id == widget.post.id);
      if (postIndex != -1) {
        final newComment = Comment(
          userName: 'Bạn',
          userAvatar: 'https://randomuser.me/api/portraits/men/9.jpg',
          timeAgo: 'Vừa xong',
          message: text,
        );

        final updatedComments = [newComment, ...dummyPosts[postIndex].commentList];

        dummyPosts[postIndex] = Post(
          id: widget.post.id,
          userName: widget.post.userName,
          userAvatar: widget.post.userAvatar,
          timeAgo: widget.post.timeAgo,
          location: widget.post.location,
          content: widget.post.content,
          images: widget.post.images,
          price: widget.post.price,
          likes: dummyPosts[postIndex].likes,
          comments: updatedComments.length,
          commentList: updatedComments,
        );

        commentController.clear();
        setState(() {}); // Refresh UI
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always get the latest post from dummyPosts
    final post = dummyPosts.firstWhere((p) => p.id == widget.post.id, orElse: () => widget.post);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bài viết của ${post.userName}'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(post.userAvatar),
                  ),
                  title: Text(post.userName),
                  subtitle: Text('${post.timeAgo} - Tại ${post.location}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange),
                    ),
                    onPressed: () {},
                    child: Text('+ Theo dõi'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.content, style: TextStyle(fontSize: 15)),
                      SizedBox(height: 8),
                      Container(
                        color: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          post.price,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
                        child: Image.network(post.images[index]),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    ],
                  ),
                ),
                Divider(),
                ...post.commentList.map((c) => CommentItem(comment: c)).toList(),
                SizedBox(height: 8),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.favorite_border),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Nhập bình luận...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _addComment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}