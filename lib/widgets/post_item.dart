import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
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
  Map<String, VideoPlayerController> videoControllers = {};

  @override
  void initState() {
    super.initState();
    isLiked = false;
    isBookmarked = false;
    bookmarksCount = 0;
    _loadLikeAndBookmarkState();
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
    for (var i = 0; i < widget.post.mediaItems.length; i++) {
      if (widget.post.mediaItems[i].type == MediaType.video) {
        // Use small, reliable video sources
        String videoUrl;
        if (i == 0) {
          videoUrl = 'https://storage.googleapis.com/exoplayer-test-media-0/BigBuckBunny_320x180.mp4';
        } else if (i == 1) {
          videoUrl = 'https://storage.googleapis.com/exoplayer-test-media-0/BigBuckBunny_320x180.mp4';
        } else {
          videoUrl = 'https://storage.googleapis.com/exoplayer-test-media-0/BigBuckBunny_320x180.mp4';
        }

        final controller = VideoPlayerController.network(videoUrl);
        videoControllers[widget.post.mediaItems[i].url] = controller;

        // Initialize with error handling
        controller.initialize().then((_) {
          if (mounted) setState(() {});
        }).catchError((error) {
          print("Error initializing video: $error");
        });
      }
    }
  }

  Widget _buildMediaItem(MediaItem item) {
    if (item.type == MediaType.image) {
      return Image.network(
        item.url,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: Center(child: Icon(Icons.broken_image, size: 40)),
          );
        },
      );
    } else {
      final controller = videoControllers[item.url];
      if (controller != null && controller.value.isInitialized) {
        return Container(
          // Limit video size to prevent memory issues
          height: 200,
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(controller),
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
            ),
          ),
        );
      } else {
        return Container(
          height: 200,
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }
    }
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
                    if (post.mediaItems[index].type == MediaType.video)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Icon(Icons.videocam, color: Colors.white),
                      ),
                  ],
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
                    isBookmarked ? Icons.star : Icons.star_border,
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