import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thaqib/screens/admin/admin_home_page.dart';
import 'package:thaqib/screens/admin/webview_page.dart';

class AdminMapPage extends StatefulWidget {
  const AdminMapPage({super.key});

  @override
  State<AdminMapPage> createState() => _AdminMapPageState();
}

class _AdminMapPageState extends State<AdminMapPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> _deleteLink(String docId) async {
    await FirebaseFirestore.instance.collection('map_links').doc(docId).delete();
  }

  void _showAddLinkDialog() {
    String errorMessage = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة رابط جديد'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'عنوان الرابط'),
                  textAlign: TextAlign.right,
                ),
                TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(labelText: 'رابط الخريطة'),
                  textAlign: TextAlign.right,
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'الوصف'),
                  textAlign: TextAlign.right,
                  maxLines: 3,
                ),
                if (errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.black54),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final link = _linkController.text.trim();
                final desc = _descController.text.trim();

                if (title.isEmpty || link.isEmpty || desc.isEmpty) {
                  setState(() {
                    errorMessage = 'الرجاء تعبئة جميع الحقول قبل الإضافة';
                  });
                  return;
                }

                await FirebaseFirestore.instance.collection('map_links').add({
                  'title': title,
                  'url': link,
                  'description': desc,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                _titleController.clear();
                _linkController.clear();
                _descController.clear();
                Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminHomeScreen())),
        ),
        centerTitle: true,
        title: const Text(
          'خريطة التلوث الضوئي',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _showAddLinkDialog,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/gradient.png', fit: BoxFit.cover),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('map_links')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(
                    child: Text('لا توجد روابط حالياً',
                        style: TextStyle(color: Colors.white)));
              }

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final url = data['url'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => _deleteLink(docs[index].id),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (url.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WebViewScreen(url: url),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    data['title'] ?? '',
                                    style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (data['description'] != null &&
                                      data['description'].toString().isNotEmpty)
                                    Text(
                                      data['description'],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}
