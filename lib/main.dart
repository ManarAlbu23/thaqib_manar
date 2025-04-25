import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:thaqib/screens/user/homePage.dart';
import 'package:thaqib/screens/admin/admin_home_page.dart';
import 'package:thaqib/screens/LogIn.dart';
import 'package:thaqib/screens/SignUp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return LoginScreen();
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final isAdmin = doc.data()?['role'] == 'admin';

    return isAdmin ? const AdminHomeScreen() : const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('خطأ في التحميل')),
            );
          } else {
            return snapshot.data!;
          }
        },
      ),
      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignUpScreen(),
        '/home': (_) => const HomeScreen(),
        '/adminHome': (_) => const AdminHomeScreen(),
      },
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thaqib/screens/user/homePage.dart';
import 'package:thaqib/screens/LogIn.dart';
import 'package:thaqib/screens/SignUp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // تحديد صفحة البداية بناءً على حالة تسجيل الدخول
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : HomeScreen(),
      // تعريف المسارات للتنقل
      routes: {
        '/login': (_) => LoginScreen(),
        '/signup': (_) => SignUpScreen(),
        '/home': (_) => HomeScreen(),
      },
    );
  }
}*/
