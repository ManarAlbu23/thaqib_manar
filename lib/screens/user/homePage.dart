import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/user/account_page.dart';
import 'package:thaqib/screens/user/map_page.dart';
import 'package:thaqib/screens/user/notifi_page.dart';
import 'package:thaqib/screens/Twitter/users/all_tweets_page.dart';
import 'package:thaqib/screens/Twitter/repository/twitter_repository.dart';
import 'package:thaqib/screens/Twitter/models/tweet_with_user.dart';
import 'package:thaqib/screens/Twitter/users/twitter_card.dart';
import 'package:thaqib/screens/Twitter/services/twitter_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/ar_messages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  List<TweetWithUser> tweets = [];
  bool isLoading = true;
  String userName = '';
  String userImage = '';

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    fetchTweets();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userName = data?['name'] ?? 'مستخدم';
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
      print('Error fetching tweets: $e');
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapPageUser())),
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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotifiPage())),
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
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
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
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AllTweetsPage())),
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



/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thaqib/screens/user/allTweetsPage.dart';
import 'package:thaqib/screens/user/account_page.dart';
import 'package:thaqib/screens/user/map_page.dart';
import 'package:thaqib/screens/user/notifi_page.dart';
import 'package:thaqib/screens/Twitter/services/twitter_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/ar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  List<TweetWithUser> tweets = [];
  bool isLoading = true;
  String userName = '';
  String userImage = '';

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    fetchTweets();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userName = data?['name'] ?? 'مستخدم';
          userImage = data?['imageUrl'] ?? '';
        });
      }
    }
  }

  Future<void> fetchTweets() async {
    try {
      final twitterService = TwitterService();
      final fetchedTweets = await twitterService.getTweetsFromFirestore();

      setState(() {
        tweets = fetchedTweets;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching tweets: $e');
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MapPageUser()));
              },
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
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(userImage),
                radius: 18,
              ),
            )
                : IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/homeBg.png", fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // إشعاراتي
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
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => NotifiPage()));
                            },
                            child: const Text("عرض الكل", style: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                          Row(
                            children: const [
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
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text('لا توجد إشعارات حالياً', style: TextStyle(color: Colors.white));
                          }

                          final doc = snapshot.data!.docs.first;
                          final data = doc.data() as Map<String, dynamic>;
                          final timestamp = data['timestamp'] as Timestamp?;
                          final timeText = timestamp != null ? timeago.format(timestamp.toDate(), locale: 'ar') : 'بدون وقت';

                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.right),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(timeText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // تويتر
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
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AllTweetsPage()));
                            },
                            child: const Text("عرض الكل", style: TextStyle(color: Colors.white, fontSize: 14)),
                          ),
                          const Row(
                            children: [
                              Text(" 𝕏 أهم الأخبار من منصة ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: tweets.map((tweet) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(tweet.author.profileImageUrl ?? ""),
                                      radius: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(tweet.author.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text("@${tweet.author.username}", style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(tweet.tweet.text, style: const TextStyle(fontSize: 14), textAlign: TextAlign.right),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('yyyy/MM/dd - HH:mm').format(tweet.tweet.createdAt!),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF3D0066),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'مستكشفون'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'تعلم'),
          BottomNavigationBarItem(icon: SizedBox(height: 35, child: Image.asset('assets/barStar.png')), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'التقويم'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thaqib/screens/user/allTweetsPage.dart';
import 'package:thaqib/screens/user/account_page.dart';
import 'package:thaqib/screens/user/map_page.dart';
import 'package:thaqib/screens/user/notifi_page.dart';
import 'package:thaqib/screens/user/twitter_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago/src/messages/ar_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';





class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  List<TweetWithUser> tweets = [];
  bool isLoading = true;
  String userName = '';
  String userImage = '';
  String? userImageUrl;




  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    fetchTweets();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userName = data?['name'] ?? 'مستخدم';
          userImage = data?['imageUrl'] ?? ''; // هنا نجيب الصورة
        });
      }
    }
  }


  Future<void> fetchTweets() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedTweets = prefs.getString('cached_tweets');

    if (cachedTweets != null) {
      final List<dynamic> jsonList = jsonDecode(cachedTweets);
      final List<TweetWithUser> cachedList = jsonList.map((json) => TweetWithUser.fromJson(json)).toList();

      if (mounted) {
        setState(() {
          tweets = cachedList;
          isLoading = false;
        });
      }
    } else {
      try {
        final twitterService = TwitterService();
        final fetchedTweets = await twitterService.fetchLatestTweets(maxResults: 2);

        if (mounted) {
          setState(() {
            tweets = fetchedTweets;
            isLoading = false;
          });
        }

        final List<Map<String, dynamic>> jsonList = fetchedTweets.map((tweet) => tweet.toJson()).toList();
        await prefs.setString('cached_tweets', jsonEncode(jsonList));
      } catch (e) {
        print('Error fetching tweets: $e');
      }
    }
  }

// Home is the default selected tab
  void _onItemTapped(int index) {
 /* if (index == 3) { // If "التقويم" is clicked
  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CalendarScreen()), // ✅ Navigate to CalendarScreen

  );
  }else if (index == 0) { // 🔹 If مستكشفون is clicked, navigate to CommunityScreen
  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CommunityScreen()),
  );
  }*/
  if(index == 4){
  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ProfilePage()),
  );
  }/*else if(index == 1){
  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => EduCategoryScreen()),
  );
  }*/else {
  setState(() {
  _selectedIndex = index; // Update the selected index
  });
  }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MapPageUser()));
              },
              child: SizedBox(
                width: 32,
                height: 32,
                child: Image.asset(
                  'assets/globe_icon.png',
                  fit: BoxFit.contain,
                ),
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
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(userImage),
                radius: 18,
              ),
            )
                : IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/homeBg.png",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // إشعاراتي
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
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => NotifiPage()));
                            },
                            child: const Text(
                              "عرض الكل",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.notifications, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                "إشعاراتي",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .orderBy('timestamp', descending: true)
                            .limit(1)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Text(
                              'لا توجد إشعارات حالياً',
                              style: TextStyle(color: Colors.white),
                            );
                          }

                          final doc = snapshot.data!.docs.first;
                          final data = doc.data() as Map<String, dynamic>;
                          final timestamp = data['timestamp'] as Timestamp?;
                          final timeText = timestamp != null
                              ? timeago.format(timestamp.toDate(), locale: 'ar')
                              : 'بدون وقت';

                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  data['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    timeText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // أهم الأخبار من X
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
                            onPressed: () {
                             // Navigator.push(context, MaterialPageRoute(builder: (_) => const AllTweetsPage()));
                            },
                            child: const Text(
                              "عرض الكل",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          const Row(
                            children: [
                              Text(
                                " 𝕏 أهم الأخبار من منصة ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: tweets.take(2).map((tweet) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(tweet.author.profileImageUrl ?? ""),
                                      radius: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tweet.author.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "@${tweet.author.username}",
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  tweet.tweet.text,
                                  style: const TextStyle(fontSize: 14),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('yyyy/MM/dd - HH:mm').format(tweet.tweet.createdAt!),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF3D0066),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'مستكشفون',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'تعلم',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 35,
              child: Image.asset('assets/barStar.png'),
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'التقويم',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),

    );
  }
}
*/
/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:thaqib/screens/user/allTweetsPage.dart';
import 'package:thaqib/screens/user/account_page.dart';
import 'package:thaqib/screens/user/map_page.dart';
import 'package:thaqib/screens/user/notifi_page.dart';
import 'package:thaqib/screens/user/twitter_service.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  List<TweetData> tweets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTweets();
  }

  Future<void> fetchTweets() async {
    final twitterService = TwitterService();
    final fetchedTweets = await twitterService.fetchLatestTweets(maxResults: 2);
    setState(() {
      tweets = fetchedTweets;
      isLoading = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 2:
        break;
    }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => map_page()));
              },
              child: SizedBox(
                width: 32,
                height: 32,
                child: Image.asset(
                  'assets/globe_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "! مرحبا، ${widget.userName}",
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
            IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccountPage()));
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/homeBg.png",
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
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
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => notifi_page()));
                            },
                            child: const Text(
                              "عرض الكل",
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.notifications, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                "إشعاراتي",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .orderBy('timestamp', descending: true)
                            .limit(4)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "لا توجد إشعارات حاليًا",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          return Column(
                            children: snapshot.data!.docs.map((doc) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 5),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    doc['title'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "أهم الأخبار من منصة 𝕏",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                        children: tweets.map((tweet) {
                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tweet.text,
                                    style: const TextStyle(fontSize: 16, color: Colors.black),
                                  ),
                                  const SizedBox(height: 8),
                                    Text(
                                      (tweet.createdAt != null)
                                          ? tweet.createdAt!.toLocal().toString()
                                          : "تاريخ غير متوفر",
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AllTweetsPage()),
                            );
                          },
                          child: const Text("عرض جميع الأخبار"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/
