import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/admin/admin_map_page.dart';
import 'package:thaqib/screens/admin/admin_notifi_page.dart';
import 'package:thaqib/screens/Twitter/admin/adminTwitterNews.dart';
import 'package:thaqib/screens/Twitter/repository/twitter_repository.dart';
import 'package:thaqib/screens/Twitter/models/tweet_with_user.dart';
import 'package:thaqib/screens/Twitter/users/twitter_card.dart';
import 'package:thaqib/screens/user/account_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/ar_messages.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 2;
  String userName = '';
  String userImage = '';
  List<TweetWithUser> tweets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    fetchUserData();
    fetchTweets();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userName = data?['name'] ?? 'مشرف';
          userImage = data?['imageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> fetchTweets() async {
    try {
      final repository = TwitterRepository();
      final fetchedTweets = await repository.getTweetsFromFirestore();
      setState(() {
        tweets = fetchedTweets;
        isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في جلب التغريدات: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMapPage())),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Image.asset('assets/globe_icon.png', fit: BoxFit.contain),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "! مرحبا، $userName",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            userImage.isNotEmpty
                ? GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
              child: CircleAvatar(backgroundImage: NetworkImage(userImage), radius: 18),
            )
                : IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/homeBg.png", fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              children: [
                // إشعارات
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotifiPage())),
                            child: const Text("عرض الكل", style: TextStyle(color: Colors.white)),
                          ),
                          const Row(
                            children: [
                              Icon(Icons.notifications, color: Colors.white),
                              SizedBox(width: 5),
                              Text("إشعاراتي", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .orderBy('timestamp', descending: true)
                            .limit(3)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.white));
                          }

                          final docs = snapshot.data!.docs;

                          return Column(
                            children: docs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final timestamp = data['timestamp'] as Timestamp?;
                              final date = timestamp?.toDate();
                              String timeText = '';
                              if (date != null) {
                                final duration = DateTime.now().difference(date);
                                if (duration.inDays <= 7) {
                                  timeText = timeago.format(date, locale: 'ar');
                                } else {
                                  timeText = DateFormat('yyyy/MM/dd - HH:mm').format(date);
                                }
                              }

                              return Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // قسم تويتر
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TwitterNewsAdmin())),
                            child: const Text("عرض الكل", style: TextStyle(color: Colors.white)),
                          ),
                          const Text("𝕏 أهم الأخبار من منصة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: tweets.take(2).map((tweet) => TwitterCard(tweet: tweet)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF3D0066),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'مستكشفون'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'تعلم'),
          BottomNavigationBarItem(
            icon: SizedBox(height: 35, child: Image(image: AssetImage('assets/barStar.png'))),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'التقويم'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
