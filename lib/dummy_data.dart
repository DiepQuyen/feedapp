// lib/dummy_data.dart

import 'models/post.dart';
import 'models/comment.dart';

final dummyPosts = [
  Post(
    id: 'p1',
    userName: 'Shop online',
    userAvatar: 'https://randomuser.me/api/portraits/women/1.jpg',
    timeAgo: '20 Phút trước',
    location: 'Thanh Xuân, Hà Nội',
    content: 'Mình có 01 túi sách hiệu Louis Vuitton mới 100% cần bán gấp.\nBạn nào cần liên hệ mình...',
    images: [
      'https://images.unsplash.com/photo-1517841905240-472988babdf9',
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e',
    ],
    price: '100.000.000 VNĐ',
    likes: 8,
    comments: 2,
    commentList: [
      Comment(
        userName: 'Linda Kiều',
        userAvatar: 'https://randomuser.me/api/portraits/women/2.jpg',
        timeAgo: '3 Giờ trước',
        message: 'Đẹp quá <3',
      ),
      Comment(
        userName: 'Hàng hiệu 100%',
        userAvatar: 'https://randomuser.me/api/portraits/men/3.jpg',
        timeAgo: '3 Ngày trước',
        message: 'Nhìn cũng được đấy :)))',
      ),
    ],
  ),
  Post(
    id: 'p2',
    userName: 'Luxury Store',
    userAvatar: 'https://randomuser.me/api/portraits/men/4.jpg',
    timeAgo: '1 Giờ trước',
    location: 'Quận 1, TP.HCM',
    content: 'Đồng hồ Rolex chính hãng, full box, bảo hành 5 năm.',
    images: [
      'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    ],
    price: '250.000.000 VNĐ',
    likes: 20,
    comments: 8,
    commentList: [
      Comment(
        userName: 'Ngọc Trinh',
        userAvatar: 'https://randomuser.me/api/portraits/women/5.jpg',
        timeAgo: '30 Phút trước',
        message: 'Có giảm giá không shop?',
      ),
    ],
  ),
  Post(
    id: 'p3',
    userName: 'Fashionista',
    userAvatar: 'https://randomuser.me/api/portraits/women/6.jpg',
    timeAgo: '2 Ngày trước',
    location: 'Đống Đa, Hà Nội',
    content: 'Giày Gucci size 38, mới 99%, tặng kèm hộp và túi giấy.',
    images: [
      'https://images.unsplash.com/photo-1512436991641-6745cdb1723f',
    ],
    price: '12.000.000 VNĐ',
    likes: 5,
    comments: 2,
    commentList: [
      Comment(
        userName: 'Minh Tú',
        userAvatar: 'https://randomuser.me/api/portraits/men/7.jpg',
        timeAgo: '1 Ngày trước',
        message: 'Còn hàng không bạn?',
      ),
      Comment(
        userName: 'Hà Anh',
        userAvatar: 'https://randomuser.me/api/portraits/women/8.jpg',
        timeAgo: '2 Ngày trước',
        message: 'Đẹp quá!',
      ),
    ],
  ),
  // Add more posts as needed...
];