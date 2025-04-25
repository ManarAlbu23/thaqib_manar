import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/Twitter/models/tweet_with_user.dart';
import 'package:thaqib/screens/Twitter/services/twitter_service.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class AllTweetsPage extends StatefulWidget {
  const AllTweetsPage({super.key});

  @override
  State<AllTweetsPage> createState() => _AllTweetsPageState();
}

class _AllTweetsPageState extends State<AllTweetsPage> {
  late Future<List<TweetWithUser>> tweets;

  @override
  void initState() {
    super.initState();
    tweets = TwitterService().getTweetsFromFirestore();
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
          "  𝕏  أهم الأخبار من منصة",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/gradient.png", fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
            child: FutureBuilder<List<TweetWithUser>>(
              future: tweets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "حدث خطأ أثناء تحميل التغريدات",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد تغريدات حالياً",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final tweets = snapshot.data!;
                return ListView.builder(
                  itemCount: tweets.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];
                    final isRetweet = tweet.tweet.referencedTweets != null &&
                        tweet.tweet.referencedTweets!
                            .any((ref) => ref.type == TweetType.retweeted);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    tweet.author.profileImageUrl ?? "",
                                  ),
                                  radius: 20,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tweet.author.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "@${tweet.author.username}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (isRetweet)
                              const Text(
                                "🔁 تمت إعادة التغريد",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            const SizedBox(height: 4),
                            Text(
                              tweet.tweet.text,
                              style: const TextStyle(fontSize: 15),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                DateFormat('yyyy/MM/dd - HH:mm').format(
                                  tweet.tweet.createdAt ?? DateTime.now(),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}






/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/user/twitter_service.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class AllTweetsPage extends StatefulWidget {
  const AllTweetsPage({super.key});

  @override
  State<AllTweetsPage> createState() => _AllTweetsPageState();
}

class _AllTweetsPageState extends State<AllTweetsPage> {
  late Future<List<TweetWithUser>> tweets;

  @override
  void initState() {
    super.initState();
    tweets = TwitterService().fetchLatestTweets(maxResults: 20);
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
          "كل الأخبار من منصة X",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/gradient.png", fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
            child: FutureBuilder<List<TweetWithUser>>(
              future: tweets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "حدث خطأ أثناء تحميل التغريدات",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد تغريدات حالياً",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final tweets = snapshot.data!;
                return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];
                    final isRetweet = tweet.tweet.referencedTweets != null &&
                        tweet.tweet.referencedTweets!
                            .any((ref) => ref.type == TweetType.retweeted);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    tweet.author.profileImageUrl ?? "",
                                  ),
                                  radius: 20,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tweet.author.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "@${tweet.author.username}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  ...(tweet.tweet.referencedTweets?.any(
                                          (ref) => ref.type.toString() == 'TweetType.retweet') ??
                                      false
                                      ? [
                                    const TextSpan(
                                      text: 'تمت إعادة التغريد 🔁\n',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ]
                                      : []),
                                  TextSpan(
                                    text: tweet.tweet.text,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.right,
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),

                            const SizedBox(height: 5),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/



/*import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/user/twitter_service.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class AllTweetsPage extends StatefulWidget {
  const AllTweetsPage({super.key});

  @override
  State<AllTweetsPage> createState() => _AllTweetsPageState();
}

class _AllTweetsPageState extends State<AllTweetsPage> {
  late Future<List<Map<String, dynamic>>> tweets;

  @override
  void initState() {
    super.initState();
    tweets = TwitterService().fetchLatestTweets(maxResults: 20);// عدد أكثر من التغريدات
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
          "كل الأخبار من منصة X",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // الخلفية
          Positioned.fill(
            child: Image.asset(
              "assets/gradient.png",
              fit: BoxFit.cover,
            ),
          ),

          // المحتوى
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
            child: FutureBuilder<List<TweetData>>(
              future: tweets,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("حدث خطأ أثناء تحميل التغريدات", style: TextStyle(color: Colors.white)),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("لا توجد تغريدات حالياً", style: TextStyle(color: Colors.white)),
                  );
                }

                final tweets = snapshot.data!;
                return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tweet.text,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('yyyy/MM/dd - HH:mm').format(tweet.createdAt!),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}*/
