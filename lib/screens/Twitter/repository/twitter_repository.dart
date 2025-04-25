import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import '../models/tweet_with_user.dart';

class TwitterRepository {
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
