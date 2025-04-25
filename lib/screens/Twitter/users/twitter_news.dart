import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TwitterNewsUser extends StatelessWidget {
  const TwitterNewsUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1031),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'أخبار منصة X',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tweets')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد تغريدات حالياً',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final tweetText = data['text'] ?? '';
              final authorName = data['authorName'] ?? '';
              final authorUsername = data['authorUsername'] ?? '';
              final authorImage = data['authorImage'] ?? '';
              final createdAt = data['createdAt'] != null
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(authorImage),
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "@$authorUsername",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tweetText,
                        style: const TextStyle(fontSize: 15),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat('yyyy/MM/dd - HH:mm').format(createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/user/twitter_service.dart';

class TwitterNews extends StatefulWidget {
  const TwitterNews({Key? key}) : super(key: key);

  @override
  _TwitterNewsState createState() => _TwitterNewsState();
}

class _TwitterNewsState extends State<TwitterNews> {
  List<TweetWithUser> tweets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTweets();
  }

  Future<void> fetchTweets() async {
    final fetchedTweets = await TwitterService().fetchLatestTweets(maxResults: 2);
    if (mounted) {
      setState(() {
        tweets = fetchedTweets;
        isLoading = false;
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "أهم الأخبار من منصة X",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/homeBg.png", fit: BoxFit.cover),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tweets.length,
            itemBuilder: (context, index) {
              final tweet = tweets[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                            NetworkImage(tweet.author.profileImageUrl ?? ""),
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
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          DateFormat('yyyy/MM/dd - HH:mm').format(
                            tweet.tweet.createdAt!,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}*/





/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'dart:convert';
import 'twitter_service.dart';

class TwitterNews extends StatefulWidget {
  const TwitterNews({Key? key}) : super(key: key);

  @override
  _TwitterNewsState createState() => _TwitterNewsState();
}

class _TwitterNewsState extends State<TwitterNews> {
  List<TweetData> tweets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTweets();
  }

  Future<void> fetchTweets() async {
    try {
      print("🔄 التحقق من آخر تحديث...");

      final prefs = await SharedPreferences.getInstance();
      final lastFetchTime = prefs.getInt('last_fetch_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      // ✅ إذا لم تمر 10 دقائق، لا تطلب من API
      if (currentTime - lastFetchTime < 10 * 60 * 1000) {
        print("⚡ استخدام التخزين المؤقت بدلاً من استعلام API");
        final cachedTweets = prefs.getString('cached_tweets');
        if (cachedTweets != null) {
          final List<dynamic> jsonList = jsonDecode(cachedTweets);
          setState(() {
            tweets = jsonList.map((e) => TweetData.fromJson(e)).toList();
            isLoading = false;
          });
          return;
        }
      }

      print("🌍 جلب التغريدات من API...");
      List<TweetData> fetchedTweets = await TwitterService().fetchLatestTweets(maxResults: 5);

      setState(() {
        tweets = fetchedTweets;
        isLoading = false;
      });

      // ✅ تحديث وقت آخر طلب ناجح
      await prefs.setInt('last_fetch_time', currentTime);
    } catch (e) {
      print("❌ خطأ أثناء جلب التغريدات: $e");
      setState(() {
        isLoading = false;
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "أهم الأخبار من منصة X",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/homeBg.png", fit: BoxFit.cover),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            itemCount: tweets.length,
            itemBuilder: (context, index) {
              final tweet = tweets[index];
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tweet.text,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('yyyy/MM/dd - HH:mm')
                            .format(tweet.createdAt!),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
*/