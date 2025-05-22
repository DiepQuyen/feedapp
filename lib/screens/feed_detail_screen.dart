import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
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
  bool isLiked = false;
  final TextEditingController commentController = TextEditingController();
  Map<String, VideoPlayerController> videoControllers = {};

  @override
  void initState() {
    super.initState();
    _loadLikeState();
    _initializeVideoControllers();
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (var controller in videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeVideoControllers() {
    final post = dummyPosts.firstWhere(
            (p) => p.id == widget.post.id,
        orElse: () => widget.post
    );

    for (var item in post.mediaItems) {
      if (item.type == MediaType.video) {
        final controller = VideoPlayerController.network(item.url);
        videoControllers[item.url] = controller;
        controller.initialize().then((_) {
          // Ensure the first frame is shown
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLikeState();
  }

  Future<void> _loadLikeState() async {
    final prefs = await SharedPreferences.getInstance();
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
        mediaItems: dummyPosts[postIndex].mediaItems,
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
          mediaItems: dummyPosts[postIndex].mediaItems,
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

  Widget _buildMediaItem(MediaItem item) {
    if (item.type == MediaType.image) {
      return Image.network(
        item.url,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else {
      final controller = videoControllers[item.url];
      if (controller != null && controller.value.isInitialized) {
        return Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            IconButton(
              icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                });
              },
            ),
          ],
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always get the latest post from dummyPosts
    final post = dummyPosts.firstWhere(
            (p) => p.id == widget.post.id,
        orElse: () => widget.post
    );

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
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.mediaItems.length,
                    itemBuilder: (ctx, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            width: 300,
                            child: _buildMediaItem(post.mediaItems[index]),
                          ),
                          Positioned(
                            top: 0,
                            left: 8,
                            child: Container(
                              color: Colors.black,
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Text(
                                post.price,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
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