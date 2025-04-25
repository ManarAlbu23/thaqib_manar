import 'package:twitter_api_v2/twitter_api_v2.dart';

class TweetWithUser {
  final TweetData tweet;
  final UserData author;

  TweetWithUser({
    required this.tweet,
    required this.author,
  });

  // يمكن تستخدمه إذا تبين تخزنينه بصيغة JSON
  Map<String, dynamic> toJson() {
    return {
      'tweet': tweet.toJson(),
      'author': author.toJson(),
    };
  }

  factory TweetWithUser.fromJson(Map<String, dynamic> json) {
    return TweetWithUser(
      tweet: TweetData.fromJson(json['tweet']),
      author: UserData.fromJson(json['author']),
    );
  }
}
