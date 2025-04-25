import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Function to handle sign-up
  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('كلمة المرور غير متطابقة');
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = _auth.currentUser;
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': _nameController.text.trim(),
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'profileImage': '', // تحدث لاحقاً
        'createdAt': Timestamp.now(),
      });


      // Navigate to login screen if sign-up is successful
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? 'حدث خطأ أثناء التسجيل');
    } catch (e) {
      _showErrorDialog('حدث خطأ غير متوقع');
    }
  }

  // Function to display error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/gradient.png'), // Background Image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView( // Scroll view for better screen fit
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Image.asset('assets/IMG_3460 1.png', width: 200, height: 150), // Smaller Logo
                    const SizedBox(height: 10),
                    const Text(
                      'مرحبًا بك\n..تسجيل جديد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name Field with Title
                    _buildLabeledTextField('الاسم', 'ادخل اسمك', _nameController),
                    const SizedBox(height: 15),

                    // Username Field with Title
                    _buildLabeledTextField('اسم المستخدم', 'ادخل اسم المستخدم', _usernameController),
                    const SizedBox(height: 15),

                    // Email Field with Title
                    _buildLabeledTextField('البريد الإلكتروني', 'ادخل بريدك الإلكتروني', _emailController),
                    const SizedBox(height: 15),

                    // Password Field with Title
                    _buildLabeledTextField('كلمة المرور', 'ادخل كلمة المرور', _passwordController, obscureText: true),
                    const SizedBox(height: 15),

                    // Confirm Password Field with Title
                    _buildLabeledTextField('تأكيد كلمة المرور', 'اعد كتابة كلمة المرور', _confirmPasswordController, obscureText: true),
                    const SizedBox(height: 20),

                    // Sign Up Button (Smaller)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 60),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _signUp,
                      child: const Text(
                        'تسجيل',
                        style: TextStyle(
                          color: Color(0xFF3D0066),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Already Have Account? Prompt
                    _buildSignInPrompt(context),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build labeled TextFields with a title above
  Widget _buildLabeledTextField(String label, String hint, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          obscureText: obscureText,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[300]),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Sign-in Prompt to navigate back to login
  Widget _buildSignInPrompt(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/login');  // Navigates to login screen
          },
          child: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'هل لديك حساب؟',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}