import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/Twitter/models/tweet_with_user.dart';

class TwitterCard extends StatelessWidget {
  final TweetWithUser tweet;

  const TwitterCard({super.key, required this.tweet});

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(tweet.author.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("@${tweet.author.username}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundImage: NetworkImage(tweet.author.profileImageUrl ?? ""),
                radius: 20,
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
  }
}
