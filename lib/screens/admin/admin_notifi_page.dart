import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thaqib/screens/user/homepage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

class AdminNotifiPage extends StatefulWidget {
  const AdminNotifiPage({super.key});

  @override
  State<AdminNotifiPage> createState() => _AdminNotifiPageState();
}

class _AdminNotifiPageState extends State<AdminNotifiPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  Future<void> _addNotification() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isNotEmpty && desc.isNotEmpty) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'description': desc,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _titleController.clear();
      _descController.clear();
      Navigator.pop(context);
    }
  }

  Future<void> _deleteNotification(String docId) async {
    await FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
  }

  void _showAddNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة إشعار جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'عنوان الإشعار'),
                textAlign: TextAlign.right,
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                textAlign: TextAlign.right,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _addNotification,
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1031),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'إدارة الإشعارات',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _showAddNotificationDialog,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد إشعارات حالياً',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>? ?? {};
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

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => _deleteNotification(doc.id),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['description'] ?? '',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                timeText,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
