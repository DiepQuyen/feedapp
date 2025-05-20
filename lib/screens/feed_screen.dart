// lib/screens/feed_screen.dart

import 'package:flutter/material.dart';
import '../widgets/post_item.dart';
import '../widgets/app_bottom_nav.dart';
import '../dummy_data.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Hàng hiệu cao cấp',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
      ),
      body: ListView.builder(
        itemCount: dummyPosts.length,
        itemBuilder: (ctx, index) {
          return PostItem(post: dummyPosts[index]);
        },
      ),
      bottomNavigationBar: AppBottomNav(currentIndex: 1),
    );
  }
}
