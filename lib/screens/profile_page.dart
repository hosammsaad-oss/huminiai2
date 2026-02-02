// ========================= الجزء 1 =========================
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

// ========================= ثوابت الألوان =========================
const Color kPrimary = Color(0xFF6B4EFF); // أزرق بنفسجي
const Color kSecondary = Color(0xFF8E78FF); // ثانوي
const Color kAccent = Color(0xFFFFC107); // للأزرار والشارات
const Color kBackground = Color(0xFFF5F5F5); // خلفية عامة فاتحة
const Color kCard = Colors.white; // خلفية الكروت
const Color kShadow = Colors.grey; // الظلال
const Color kFollow = Color(0xFF4CAF50); // زر متابعة أخضر
const Color kUnfollow = Color(0xFF9E9E9E); // زر إلغاء متابعة رمادي
const Color kDM = Color(0xFF00BFA5); // زر الرسائل

// ========================= البروفايل الرئيسي =========================
class EnhancedProfilePage extends StatefulWidget {
  final String userId;
  const EnhancedProfilePage({super.key, required this.userId});

  @override
  State<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
}

// ========================= Follow Button =========================
class FollowButton extends StatefulWidget {
  final String profileUserId;
  const FollowButton({super.key, required this.profileUserId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  Future<void> _checkFollowing() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('followers')
        .doc(widget.profileUserId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  Future<void> _toggleFollow() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference followerRef = FirebaseFirestore.instance
        .collection('followers')
        .doc(widget.profileUserId)
        .collection('userFollowers')
        .doc(currentUserId);

    DocumentReference followingRef = FirebaseFirestore.instance
        .collection('following')
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileUserId);

    if (isFollowing) {
      await followerRef.delete();
      await followingRef.delete();
    } else {
      await followerRef.set({'timestamp': FieldValue.serverTimestamp()});
      await followingRef.set({'timestamp': FieldValue.serverTimestamp()});
    }

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? kUnfollow : kFollow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(isFollowing ? "Unfollow" : "Follow",
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

// ========================= Message Button =========================
class MessageButton extends StatelessWidget {
  final String profileUserId;
  const MessageButton({super.key, required this.profileUserId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ChatScreen(chatUserId: profileUserId)));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kDM,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: const Text("DM",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}

// ========================= Chat Screen =========================
class ChatScreen extends StatelessWidget {
  final String chatUserId;
  const ChatScreen({super.key, required this.chatUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with $chatUserId",
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        backgroundColor: kPrimary,
      ),
      body: const Center(
        child: Text("هنا ستكون شاشة الدردشة"),
      ),
    );
  }
}

// ========================= Level & Progress Card =========================
class LevelProgressCard extends StatelessWidget {
  final int points;
  const LevelProgressCard({super.key, required this.points});

  int getLevel(int points) => points <= 0 ? 1 : (points / 500).floor() + 1;
  double getProgress(int points) => (points % 500) / 500;

  @override
  Widget build(BuildContext context) {
    int level = getLevel(points);
    double progress = getProgress(points);

    return Card(
      color: kSecondary.withOpacity(0.1),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Level $level",
                    style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text("$points XP",
                    style: GoogleFonts.tajawal(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: kBackground,
                color: kPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: [
                Chip(
                  label: const Text("Badge 1"),
                  backgroundColor: kAccent.withOpacity(0.2),
                ),
                Chip(
                  label: const Text("Badge 2"),
                  backgroundColor: kAccent.withOpacity(0.2),
                ),
                Chip(
                  label: const Text("Badge 3"),
                  backgroundColor: kAccent.withOpacity(0.2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= AI Summary Card =========================
class AISummaryCard extends StatelessWidget {
  final String userId;
  const AISummaryCard({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kSecondary.withOpacity(0.1),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("ملخص الذكاء الاصطناعي",
                style:
                    GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              "مثال: نقاط القوة المهنية، اقتراح تحسينات للبروفايل، تحليل النشاط، اقتراح محتوى مناسب...",
              style: GoogleFonts.tajawal(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= تحديث الصور =========================
// ========================= الجزء 2 =========================

// ========================= الصفحة الرئيسية للبروفايل =========================
class _EnhancedProfilePageState extends State<EnhancedProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _eduController;

  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _eduController = TextEditingController();
    _checkFollowing();
  }

  void _checkFollowing() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('followers')
          .doc(widget.userId)
          .collection('userFollowers')
          .doc(currentUser.uid)
          .get();
      setState(() {
        _isFollowing = doc.exists;
      });
    }
  }

  Future<void> _toggleFollow() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final followerRef = FirebaseFirestore.instance
        .collection('followers')
        .doc(widget.userId)
        .collection('userFollowers')
        .doc(currentUser.uid);
    final followingRef = FirebaseFirestore.instance
        .collection('following')
        .doc(currentUser.uid)
        .collection('userFollowing')
        .doc(widget.userId);

    if (_isFollowing) {
      await followerRef.delete();
      await followingRef.delete();
    } else {
      await followerRef.set({'timestamp': FieldValue.serverTimestamp()});
      await followingRef.set({'timestamp': FieldValue.serverTimestamp()});
    }

    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _eduController.dispose();
    super.dispose();
  }

  // ========================= تحديث الصورة الشخصية =========================
  Future<void> _updateProfileImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = 'profiles/${widget.userId}.jpg';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'photoUrl': downloadUrl});
    }
  }

  // ========================= تحديث صورة الغلاف =========================
  Future<void> _updateCoverImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = 'covers/${widget.userId}.jpg';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref().child(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'coverUrl': downloadUrl});
    }
  }

  int _calculateLevel(int xp) => (xp / 500).floor() + 1;
  double _calculateProgress(int xp) => (xp % 500) / 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text('الملف الشخصي', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        backgroundColor: kBackground,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          int xp = userData['xp'] ?? 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(userData),
                const SizedBox(height: 12),

                // ========================= أزرار Follow / DM =========================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: FollowButton(profileUserId: widget.userId)),
                      const SizedBox(width: 12),
                      Expanded(child: MessageButton(profileUserId: widget.userId)),
                    ],
                  ),
                ),

                const SizedBox(height: 12),
                _buildLevelProgress(xp),
                const SizedBox(height: 12),
                _buildAISummary(userData),
                const SizedBox(height: 12),
                _buildAIRecommendation(userData),
                const SizedBox(height: 12),

                // ========================= التابات =========================
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[600],
                  indicator: BoxDecoration(
                      color: kPrimary, borderRadius: BorderRadius.circular(12)),
                  tabs: const [
                    Tab(text: 'نبذة'),
                    Tab(text: 'منشورات'),
                    Tab(text: 'خبرة'),
                    Tab(text: 'شهادات'),
                  ],
                ),
                SizedBox(
                  height: 700,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBioTab(userData),
                      _buildPostsTab(userData),
                      _buildExperienceTab(userData),
                      _buildCertificatesTab(userData),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========================= Header =========================
  Widget _buildHeader(Map<String, dynamic> userData) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _updateCoverImage,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                    userData['coverUrl'] ?? 'https://via.placeholder.com/600x200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 0,
          child: GestureDetector(
            onTap: _updateProfileImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: kBackground,
              child: CircleAvatar(
                radius: 46,
                backgroundImage: CachedNetworkImageProvider(
                    userData['photoUrl'] ?? 'https://via.placeholder.com/150'),
              ),
            ),
          ),
        ),
        Positioned(
          left: 120,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userData['name'] ?? '',
                  style: GoogleFonts.tajawal(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('@${userData['username'] ?? ''}',
                  style: GoogleFonts.tajawal(fontSize: 14, color: Colors.white70)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.green, borderRadius: BorderRadius.circular(4)),
                    child: const Text('✔️ موثق', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  Text('انضم: ${userData['joinDate'] ?? ''}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  // ========================= Level Progress Widget =========================
  Widget _buildLevelProgress(int xp) {
    int level = _calculateLevel(xp);
    double progress = _calculateProgress(xp);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('المستوى $level', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('$xp XP', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: kBackground,
              color: kPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ========================= AI Summary =========================
  Widget _buildAISummary(Map<String, dynamic> userData) {
    return AISummaryCard(userId: widget.userId);
  }

  // ========================= AI Content Recommendation =========================
  Widget _buildAIRecommendation(Map<String, dynamic> userData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('توصيات المحتوى', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('مثال: مشاركة منشورات تعليمية، فيديوهات قصيرة، نصائح تقنية.',
              style: GoogleFonts.tajawal(fontSize: 14)),
        ],
      ),
    );
  }

  // ========================= Tabs =========================
  Widget _buildBioTab(Map<String, dynamic> userData) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(userData['bio'] ?? 'لا توجد نبذة', style: GoogleFonts.tajawal(fontSize: 16)),
    );
  }

  Widget _buildPostsTab(Map<String, dynamic> userData) {
    return PostsTab(userData['uid']);
  }

  Widget _buildExperienceTab(Map<String, dynamic> userData) {
    return ExperienceTab(userData['uid']);
  }

  Widget _buildCertificatesTab(Map<String, dynamic> userData) {
    return CertificatesTab(userData['uid']);
  }
}
// ========================= الجزء 3 =========================

// ========================= PostsTab =========================
class PostsTab extends StatelessWidget {
  final String userId;
  const PostsTab(this.userId, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Center(child: Text("لا توجد منشورات"));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var post = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post['text'] != null)
                      Text(post['text'], style: GoogleFonts.tajawal(fontSize: 14)),
                    const SizedBox(height: 8),
                    if (post['mediaUrl'] != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MediaPreviewScreen(
                                  url: post['mediaUrl'], type: post['type']),
                            ),
                          );
                        },
                        child: post['type'] == 'image'
                            ? Image.network(post['mediaUrl'])
                            : VideoPlayerWidget(post['mediaUrl']),
                      ),
                    if (post['pinned'] == true)
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.amber, borderRadius: BorderRadius.circular(4)),
                        child: const Text("Pinned",
                            style: TextStyle(fontSize: 12, color: Colors.white)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ========================= ExperienceTab =========================
class ExperienceTab extends StatelessWidget {
  final String userId;
  const ExperienceTab(this.userId, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('experience')
          .where('userId', isEqualTo: userId)
          .orderBy('startDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var docs = snapshot.data!.docs;

        if (docs.isEmpty) return const Center(child: Text("لا توجد خبرات"));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var exp = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exp['position'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(exp['company'] ?? '', style: const TextStyle(color: Colors.grey)),
                    Text("${exp['startDate'] ?? ''} - ${exp['endDate'] ?? 'الحاضر'}"),
                    if (exp['description'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(exp['description']),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ========================= CertificatesTab =========================
class CertificatesTab extends StatelessWidget {
  final String userId;
  const CertificatesTab(this.userId, {super.key});

  Future<void> _uploadCertificate(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    File file = File(pickedFile.path);
    String fileName = 'certificates/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    UploadTask uploadTask = FirebaseStorage.instance.ref().child(fileName).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('certificates').add({
      'userId': userId,
      'imageUrl': downloadUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("تم رفع الشهادة بنجاح")));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _uploadCertificate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("رفع شهادة جديدة"),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('certificates')
                .where('userId', isEqualTo: userId)
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              var docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text("لا توجد شهادات"));

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var cert = docs[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MediaPreviewScreen(
                              url: cert['imageUrl'], type: 'image'),
                        ),
                      );
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Image.network(cert['imageUrl'], fit: BoxFit.cover),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ========================= Media Preview Screen =========================
class MediaPreviewScreen extends StatelessWidget {
  final String url;
  final String type; // 'image' or 'video'
  const MediaPreviewScreen({super.key, required this.url, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("معاينة"),
        backgroundColor: kPrimary,
      ),
      body: Center(
        child: type == 'image'
            ? Image.network(url)
            : VideoPlayerWidget(url),
      ),
    );
  }
}

// ========================= VideoPlayerWidget =========================
class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget(this.url, {super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const SizedBox();
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          VideoProgressIndicator(_controller, allowScrubbing: true),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying ? _controller.pause() : _controller.play();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
