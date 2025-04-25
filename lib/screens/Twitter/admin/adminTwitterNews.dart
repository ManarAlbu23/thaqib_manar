import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thaqib/screens/Twitter/services/twitter_service.dart';

class TwitterNewsAdmin extends StatefulWidget {
  const TwitterNewsAdmin({super.key});

  @override
  State<TwitterNewsAdmin> createState() => _TwitterNewsAdminState();
}

class _TwitterNewsAdminState extends State<TwitterNewsAdmin> {
  bool isLoading = false;

  Future<void> refreshTweets() async {
    setState(() => isLoading = true);
    try {
      await TwitterService().fetchAndStoreTweetsToFirestore(maxResults: 10);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحديث التغريدات بنجاح')),
      );
    } catch (e) {
      print("❌ Error refreshing tweets: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ حدث خطأ أثناء التحديث')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true, // ✅ يظهر السهم تلقائياً
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "𝕏 أهم الأخبار من منصة",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: refreshTweets,
          ),
        ],
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF1A1031),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/gradient.png", fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tweets')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('لا توجد تغريدات حالياً', style: TextStyle(color: Colors.white)),
                  );
                }

                final tweets = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tweets.length,
                  itemBuilder: (context, index) {
                    final tweet = tweets[index].data() as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
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
                                backgroundImage: NetworkImage(tweet['authorImage'] ?? ''),
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tweet['authorName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('@${tweet['authorUsername'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            tweet['text'] ?? '',
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              tweet['createdAt'] != null
                                  ? DateFormat('yyyy/MM/dd - HH:mm').format((tweet['createdAt'] as Timestamp).toDate())
                                  : '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
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
