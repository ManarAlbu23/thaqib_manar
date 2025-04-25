import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thaqib/screens/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/gradient.png"),
                  // Replace with your background image URL
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Image or Icon
                  Container(
                    margin: const EdgeInsets.only(top: 25, left: 0), // Adjust the values as needed
                    child: Image.asset(
                      'assets/thaqibStar.PNG',
                      width: 300,
                      height: 200,
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Welcome Text
                  const Text(
                    'مرحبا بك\n..تسجيل دخول',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'البريد الإلكتروني',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  // Username Field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'البريد الإلكتروني',
                      hintStyle: TextStyle(color: Colors.grey[300]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 20),

                  // Password Field with Title
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كلمة المرور',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      hintStyle: TextStyle(color: Colors.grey[300]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  // Forgot Password Text
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'هل نسيت كلمة المرور؟',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Login Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 80),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      await _login(context); // Call the login function
                    },
                    child: const Text(
                      'تسجيل دخول',
                      style: TextStyle(
                        color: Color(0xFF3D0066),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Register New Account Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignUpScreen()), // Navigate to SignUpScreen
                          );
                        },
                        child :const Text(
                          'تسجيل حساب جديد',
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
                        'ليس لديك حساب؟',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }


  // Firebase Login Function
  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );


      // Navigate to Home Page on successful login
      final uid = userCredential.user?.uid;
      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        final role = userDoc.data()?['role'];

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/adminHome'); // صفحة الأدمن
        } else {
          Navigator.pushReplacementNamed(context, '/home'); // الصفحة العادية للمستخدم
        }
      }

    }  on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'user-not-found') {
        errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير صالح.';
      } else {
        errorMessage = 'حدث خطأ: ${e.message}';
      }


      // Display an error message if login fails
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('خطأ'),
              content:Text(errorMessage),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('حسنًا'),
                ),
              ],
            ),
      );
    }
  }
  // Dialog to prompt email verification
  Future<void> _showVerificationDialog(BuildContext context, User user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد البريد الإلكتروني'),
        content: const Text(
          'يرجى التحقق من بريدك الإلكتروني وتأكيده قبل تسجيل الدخول. هل ترغب في إرسال بريد تحقق جديد؟',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () async {
              await user.sendEmailVerification();  // Resend verification email
              Navigator.pop(context);
              _showSuccessDialog(context);
            },
            child: const Text('نعم، أرسل'),
          ),
        ],
      ),
    );
  }

// Success dialog after resending verification email
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم الإرسال'),
        content: const Text('تم إرسال رابط التحقق إلى بريدك الإلكتروني.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

}


class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  // Function to send password reset email
  Future<void> _resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      // Show success message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم الإرسال'),
          content: const Text('تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني غير صالح.';
      } else {
        errorMessage = 'حدث خطأ: ${e.message}';
      }

      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('خطأ'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/gradient 1.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Image.asset('assets/IMG_3460 1.png', width: 200, height: 150), // Smaller Logo
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'استعادة كلمة المرور',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'أدخل بريدك الإلكتروني',
                      hintStyle: TextStyle(color: Colors.grey[300]),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _resetPassword,
                    child: const Text(
                      'إرسال رابط الاستعادة',
                      style: TextStyle(
                        color: Color(0xFF3D0066),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'العودة لتسجيل الدخول',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}