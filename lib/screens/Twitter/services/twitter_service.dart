import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:thaqib/screens/Twitter/models/tweet_with_user.dart';

class TwitterService {
  final twitter = TwitterApi(
    bearerToken: '...توكن تويتر حقك...',
  );

  Future<void> fetchAndStoreTweetsToFirestore({int maxResults = 10}) async {
    try {
      final response = await twitter.tweets.lookupTweets(
        userId: '1880327871409057796',
        maxResults: maxResults,
        tweetFields: [
          TweetField.createdAt,
          TweetField.text,
          TweetField.referencedTweets,
        ],
        expansions: [TweetExpansion.authorId],
        userFields: [
          UserField.name,
          UserField.username,
          UserField.profileImageUrl,
        ],
      );

      if (response.data == null || response.includes?.users == null) return;

      final usersMap = {
        for (var user in response.includes!.users!) user.id: user,
      };

      final tweets = response.data!.map((tweet) {
        final author = usersMap[tweet.authorId];
        return TweetWithUser(tweet: tweet, author: author!);
      }).toList();

      final tweetsRef = FirebaseFirestore.instance.collection('tweets');
      final batch = FirebaseFirestore.instance.batch();

      final oldTweets = await tweetsRef.get();
      for (var doc in oldTweets.docs) {
        batch.delete(doc.reference);
      }

      for (var tweet in tweets) {
        final docRef = tweetsRef.doc();
        batch.set(docRef, {
          'text': tweet.tweet.text,
          'authorName': tweet.author.name,
          'authorUsername': tweet.author.username,
          'authorImage': tweet.author.profileImageUrl ?? '',
          'createdAt': tweet.tweet.createdAt,
        });
      }

      await batch.commit();
      print('✅ تم تحديث التغريدات وتخزينها في Firestore');
    } catch (e) {
      print('❌ فشل في جلب أو تخزين التغريدات: $e');
    }
  }

  Future<List<TweetWithUser>> getTweetsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tweets')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return TweetWithUser(
        tweet: TweetData(
          id: doc.id,
          text: data['text'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        ),
        author: UserData(
          id: '',
          name: data['authorName'],
          username: data['authorUsername'],
          profileImageUrl: data['authorImage'],
        ),
      );
    }).toList();
  }
}


/*import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';

class TweetWithUser {
  final TweetData tweet;
  final UserData author;

  TweetWithUser({required this.tweet, required this.author});

  factory TweetWithUser.fromJson(Map<String, dynamic> json) {
    return TweetWithUser(
      tweet: TweetData.fromJson(json['tweet']),
      author: UserData.fromJson(json['author']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tweet': tweet.toJson(),
      'author': author.toJson(),
    };
  }
}

class TwitterService {
  final twitter = TwitterApi(
    bearerToken: 'AAAAAAAAAAAAAAAAAAAAAD7P0AEAAAAA2bvVqz3YmhfbVoKjvWr8RXQHdD4%3DdfDIDyb4dOvbdlDM4VvptEhJdkRPUaG6BQjTHLstyG1Iq9vft8',
  );

  Future<List<TweetWithUser>> fetchLatestTweets({int maxResults = 5}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedTweets = prefs.getString('cached_tweets');
      final lastFetchTime = prefs.getInt('last_fetch_time') ?? 0;
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (cachedTweets != null && (currentTime - lastFetchTime < 10 * 60 * 1000)) {
        print("⚡ تحميل من الكاش...");
        final List<dynamic> jsonList = jsonDecode(cachedTweets);
        return jsonList.map((e) => TweetWithUser.fromJson(e)).toList();
      }

      final response = await twitter.tweets.lookupTweets(
        userId: '1880327871409057796',
        maxResults: maxResults,
        tweetFields: [
          TweetField.createdAt,
          TweetField.text,
          TweetField.referencedTweets,],
        expansions: [TweetExpansion.authorId],
        userFields: [UserField.name, UserField.username, UserField.profileImageUrl],
      );

      if (response.data == null || response.includes?.users == null) return [];

      final usersMap = {
        for (var user in response.includes!.users!) user.id: user
      };

      List<TweetWithUser> tweets = response.data!.map((tweet) {
        final author = usersMap[tweet.authorId];
        return TweetWithUser(tweet: tweet, author: author!);
      }).toList();

      await prefs.setString('cached_tweets', jsonEncode(tweets));
      await prefs.setInt('last_fetch_time', currentTime);

      print("✅ الكاش محفوظ بنجاح!");

      return tweets;
    } catch (e) {
      print("خطأ في جلب التغريدات: $e");
      return [];
    }
  }
}*/




/* Future<List<TweetData>> fetchLatestTweets({int maxResults = 5}) async {
  try {
  print("🔄 استعلام API لجلب التغريدات...");

  final prefs = await SharedPreferences.getInstance();
  final cachedTweets = prefs.getString('cached_tweets');

  // ✅ تحميل التغريدات من التخزين المؤقت في حال توفرها
  if (cachedTweets != null) {
  print("⚡ تحميل التغريدات من التخزين المؤقت...");
  final List<dynamic> jsonList = jsonDecode(cachedTweets);
  return jsonList.map((e) => TweetData.fromJson(e)).toList();
  }

  // ✅ جلب التغريدات من API فقط إذا لم تكن مخزنة محليًا
  final tweetsResponse = await twitter.tweets.lookupTweets(
  userId: "1880327871409057796",
  maxResults: maxResults,
  tweetFields: [TweetField.createdAt, TweetField.text],
  );

  if (tweetsResponse.data == null) {
  print("❌ فشل في جلب التغريدات 🚨");
  return [];
  }

  print("✅ API Response: ${tweetsResponse.data}");

  // ✅ حفظ البيانات في التخزين المؤقت بعد تحويلها إلى JSON
  final List<Map<String, dynamic>> tweetsJsonList = tweetsResponse.data!
      .map((tweet) => tweet.toJson())
      .toList();

  await prefs.setString('cached_tweets', jsonEncode(tweetsJsonList));

  return tweetsResponse.data!;
  } catch (e) {
  print("❌ خطأ أثناء جلب التغريدات ❌: $e");
  return [];
  }
  }
  }
*/
