import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // خلفية هادئة
      appBar: AppBar(
        title: Text("الملف الشخصي", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {
              // تنفيذ عملية تعديل الملف الشخصي
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          final TextEditingController _nameController = TextEditingController(text: userData['name'] ?? "");
          final TextEditingController _bioController = TextEditingController();
          final TextEditingController _eduController = TextEditingController();
          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. الجزء العلوي (الغلاف والصورة الشخصية)
                _buildHeader(userData),

                // 2. إحصائيات سريعة (متابعين، رصيد إنجاز)
                _buildStatsBar(userData),

                // 3. قسم الرتبة والإنجازات
                _buildRankSection(userData),

                // 4. قسم التعليم
                _buildSectionCard(
                  title: "التعليم",
                  icon: Icons.school_rounded,
                  content: Text(
                    userData['education'] ?? "لم يتم إضافة معلومات تعليمية بعد.",
                    style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black87),
                  ),
                ),

                // 5. قسم النبذة الشخصية
                _buildSectionCard(
                  title: "عني",
                  icon: Icons.person_search_rounded,
                  content: Text(
                    userData['bio'] ?? "لا يوجد وصف متاح.",
                    style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black54),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // الجزء العلوي: الغلاف والصورة والاسم
  Widget _buildHeader(Map<String, dynamic> userData) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF6B4EFF), Color(0xFF8E78FF)]),
              ),
            ),
            Container(
              height: 80,
              width: double.infinity,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    userData['name'] ?? "اسم المستخدم",
                    style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userData['email'] ?? "",
                    style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          top: 100,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: CachedNetworkImageProvider(userData['photoUrl'] ?? 'https://via.placeholder.com/150'),
            ),
          ),
        ),
      ],
    );
  }

  // شريط الإحصائيات (LinkedIn Style)
  Widget _buildStatsBar(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("المتابعين", userData['followersCount']?.toString() ?? "0"),
          _statItem("يتابع", userData['followingCount']?.toString() ?? "0"),
          _statItem("رصيد الإنجاز", "${userData['achievementPoints'] ?? 0} نقطة"),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6B4EFF))),
        Text(label, style: GoogleFonts.tajawal(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // قسم الرتبة والإنجازات (Gamification)
  Widget _buildRankSection(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 30),
              const SizedBox(width: 10),
              Text("الرتبة: ${userData['rank'] ?? 'مبتدئ'}", 
                style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          const Text("آخر الإنجازات:"),
          const SizedBox(height: 10),
          // قائمة الإنجازات (بدل استخدام ListView نستخدم Wrap لعرض الأوسمة)
          Wrap(
            spacing: 8,
            children: [
              _buildBadge("ناشر متميز"),
              _buildBadge("أول مهمة"),
              _buildBadge("صديق الذكاء"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
      backgroundColor: const Color(0xFF6B4EFF),
      padding: const EdgeInsets.all(0),
    );
  }

  // ويدجت موحد للأقسام (مثل LinkedIn Cards)
  Widget _buildSectionCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(),
          content,
        ],
      ),
    );
  }
}



