import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'edit_profile.dart';
import 'package:thaqib/screens/logIn.dart';
import 'package:thaqib/screens/user/homePage.dart'; // Import the login page here

class ProfilePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot> getUserData() async {
    return await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    int _selectedIndex = 4;// Sign out from Firebase
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to login page
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/gradient.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: FutureBuilder<DocumentSnapshot>(
          future: getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text(
                  'لم يتم العثور على البيانات',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add the logout button here in the top-left corner
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    onPressed: () => _logout(context),
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  'معلوماتي',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData['imageUrl'] != null
                      ? NetworkImage(userData['imageUrl'])
                      : const AssetImage('assets/profile_pic.png') as ImageProvider,
                ),
                const SizedBox(height: 20),
                Text(
                  userData['name'] ?? 'الاسم غير متوفر',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '@${userData['username'] ?? 'اسم المستخدم'}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    userData['bio'] ?? 'لا توجد نبذة.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              /*  ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfileScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  child: const Text(
                    'تعديل الملف الشخصي',
                    style: TextStyle(color: Colors.black), // Set the text color to black
                  ),
                ),*/
              ],
            );
          },
        ),
      ),
      // 🔹 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF7A1E6C),
        unselectedItemColor: Colors.grey,
        currentIndex: 4, // 4 = "معلوماتي"
        onTap: (index) {
          // 👉 You can add navigation logic here if needed
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "مستكشفون"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "تعلم"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_sharp), label: "التقويم"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "معلوماتي"),
        ],
      ),
    );
  }
}