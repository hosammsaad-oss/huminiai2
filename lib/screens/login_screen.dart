import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // أضف هذا السطر

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- الدالة السحرية: إنشاء أو تحديث مستند المستخدم في Firestore ---
  Future<void> _syncUserToFirestore(User user, {String? name}) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    
    await userRef.set({
      'uid': user.uid,
      'name': name ?? user.displayName ?? "منجز مجهول",
      'email': user.email ?? "Guest",
      'photoUrl': user.photoURL ?? 'https://via.placeholder.com/150',
      'bio': 'مرحباً بك في HUMINI AI! 🚀',
      'followersCount': 0,
      'followingCount': 0,
      'postsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // استخدام merge لعدم مسح البيانات القديمة
  }

  // 1. الدخول كضيف
  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      UserCredential cred = await FirebaseAuth.instance.signInAnonymously();
      if (cred.user != null) {
        await _syncUserToFirestore(cred.user!, name: "ضيف يونيكورن");
      }
    } catch (e) {
      _showError("فشل الدخول كضيف: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. دالة جوجل
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      UserCredential cred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      if (cred.user != null) {
        await _syncUserToFirestore(cred.user!);
      }
    } catch (e) {
      _showError("فشل تسجيل الدخول بجوجل: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 3. دالة البريد الإلكتروني (إنشاء ودخول)
  Future<void> _processAuth(bool isRegistration) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showError("يرجى ملء كافة الحقول");
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserCredential cred;
      if (isRegistration) {
        cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
        // إنشاء البروفايل فور التسجيل الجديد
        if (cred.user != null) {
          await _syncUserToFirestore(cred.user!, name: email.split('@')[0]);
        }
      } else {
        cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
        // تحديث البيانات عند الدخول (اختياري لضمان وجود المستند)
        if (cred.user != null) {
          await _syncUserToFirestore(cred.user!);
        }
      }
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "حدث خطأ ما");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }

  // ... (بقية كود الـ build كما هو بدون تغيير)
  @override
  Widget build(BuildContext context) {
    // استخدم نفس الـ build الذي لديك في الكود الأصلي
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 80, color: Colors.deepPurpleAccent),
              const SizedBox(height: 10),
              const Text("HUMINI AI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "البريد الإلكتروني",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "كلمة المرور",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(color: Colors.deepPurpleAccent)
              else ...[
                ElevatedButton(
                  onPressed: () => _processAuth(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("تسجيل الدخول", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 15),
                OutlinedButton.icon(
                  onPressed: _signInWithGoogle,
                  icon: const Icon(Icons.login), // استبدلت Image.network للتجربة السريعة
                  label: const Text("الدخول بواسطة جوجل", style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _signInAnonymously,
                  child: const Text("استخدام كضيف (بدون حساب)", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                TextButton(
                  onPressed: () => _processAuth(true),
                  child: const Text("ليس لديك حساب؟ إنشاء حساب بريد", style: TextStyle(color: Colors.deepPurpleAccent)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}