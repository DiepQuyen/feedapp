// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/feed_screen.dart';

void main() {
  runApp(HangHieuApp());
}

// App chính
class HangHieuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hàng hiệu cao cấp',
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      theme: ThemeData(
        fontFamily: 'Arial',
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FeedScreen(), // Trang chính là màn hình danh sách bài đăng
    );
  }
}
