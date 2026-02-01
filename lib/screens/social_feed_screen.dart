import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
// أضف الاستيراد في أعلى ملف السوشيال ميديا
import 'profile_page.dart';




class SocialFeedScreen extends ConsumerStatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  ConsumerState<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends ConsumerState<SocialFeedScreen> {
  final Color primaryColor = const Color(0xFF6B4EFF);

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF0F2F5), // لون خلفية شبيه بفيسبوك لكن ألطف
    appBar: AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      centerTitle: false,
      title: Text(
        "يونيكورن هب ✨",
        style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: primaryColor),
      ),
      actions: [
        // --- زر تسجيل الخروج الجديد ---
        IconButton(
          icon: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            // سيقوم الـ AuthWrapper في ملف main.dart بنقلك تلقائياً لصفحة اللوجن
          },
        ),
        // ----------------------------
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    ),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final postDoc = snapshot.data!.docs[index];
            final postData = postDoc.data() as Map<String, dynamic>;
            return PostCard(postData: postData, postId: postDoc.id);
          },
        );
      },
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: primaryColor,
      child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
      onPressed: () => _showCreatePostModal(context),
    ),
  );
}

  // --- دالة عرض نافذة النشر ---
  void _showCreatePostModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostWidget(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text("لا توجد منشورات بعد.. كن أول من يلهمنا!", style: GoogleFonts.tajawal(color: Colors.grey)),
    );
  }
}

// --- ويدجت بطاقة المنشور المحترفة ---
class PostCard extends StatelessWidget {
  final Map<String, dynamic> postData;
  final String postId;

  const PostCard({super.key, required this.postData, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (postData['content'] != null && postData['content'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(postData['content'], style: GoogleFonts.tajawal(fontSize: 15)),
            ),
          if (postData['mediaUrl'] != null) _buildMediaContent(context),
          _buildInteractionBar(),
        ],
      ),
    );
  }




  Widget _buildHeader(BuildContext context) { // أضفنا context هنا
  return ListTile(
    // هذا هو التعديل الأساسي: عند الضغط على رأس المنشور
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(userId: postData['authorId']),
        ),
      );
    },
    leading: CircleAvatar(
      backgroundImage: CachedNetworkImageProvider(
          postData['authorPic'] ?? 'https://via.placeholder.com/150'),
    ),
    title: Text(
      postData['authorName'] ?? "عضو يونيكورن",
      style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    subtitle: const Text("منذ قليل", style: TextStyle(fontSize: 10)),
    trailing: OutlinedButton(
      onPressed: () {
        // هنا يمكنك وضع منطق المتابعة السريع
      },
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: Color(0xFF6B4EFF)),
      ),
      child: Text("متابعة",
          style: GoogleFonts.tajawal(fontSize: 12, color: const Color(0xFF6B4EFF))),
    ),
  );
}





  Widget _buildMediaContent(BuildContext context) {
    if (postData['mediaType'] == 'video') {
      return VideoPlayerWidget(videoUrl: postData['mediaUrl']);
    } else {
      return GestureDetector(
        onTap: () {
          // منطق Zoom Preview
        },
        child: CachedNetworkImage(
          imageUrl: postData['mediaUrl'],
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(height: 200, color: Colors.grey[200]),
        ),
      );
    }
  }

  Widget _buildInteractionBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text("${postData['likesCount'] ?? 0}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              Text("${postData['commentsCount'] ?? 0} تعليقات", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionBtn(Icons.favorite_border, "أعجبني"),
              _actionBtn(Icons.chat_bubble_outline, "تعليق"),
              _actionBtn(Icons.share_outlined, "مشاركة"),
              _actionBtn(Icons.bookmark_border, "حفظ"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(children: [Icon(icon, size: 20, color: Colors.grey[700]), const SizedBox(width: 4), Text(label, style: GoogleFonts.tajawal(fontSize: 12))]),
      ),
    );
  }
}

// --- ويدجت تشغيل الفيديو ---
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          chewieController = ChewieController(
            videoPlayerController: videoPlayerController,
            autoPlay: false,
            looping: false,
            aspectRatio: videoPlayerController.value.aspectRatio,
          );
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return chewieController != null
        ? SizedBox(height: 300, child: Chewie(controller: chewieController!))
        : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }
}

// --- ويدجت إنشاء بوست جديد (دعم الصور والفيديو) ---
class CreatePostWidget extends StatefulWidget {
  const CreatePostWidget({super.key});

  @override
  State<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;
  String _mediaType = 'text';

  Future<void> _pickFile(ImageSource source, bool isVideo) async {
    final picker = ImagePicker();
    final XFile? file = isVideo ? await picker.pickVideo(source: source) : await picker.pickImage(source: source);

    if (file != null) {
      setState(() {
        _selectedFile = File(file.path);
        _mediaType = isVideo ? 'video' : 'image';
      });
    }
  }

  Future<void> _handlePost() async {
    if (_contentController.text.isEmpty && _selectedFile == null) return;
    setState(() => _isUploading = true);

    String? mediaUrl;
    if (_selectedFile != null) {
      final ref = FirebaseStorage.instance.ref().child('posts/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(_selectedFile!);
      mediaUrl = await ref.getDownloadURL();
    }

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('posts').add({
      'authorId': user?.uid,
      'authorName': user?.displayName ?? "قناص يونيكورن",
      'authorPic': user?.photoURL,
      'content': _contentController.text,
      'mediaUrl': mediaUrl,
      'mediaType': _mediaType,
      'timestamp': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'commentsCount': 0,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
              ElevatedButton(
                onPressed: _isUploading ? null : _handlePost,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4EFF)),
                child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text("نشر", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          TextField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(hintText: "بماذا تشعر اليوم؟", border: InputBorder.none),
          ),
          if (_selectedFile != null)
            Expanded(child: _mediaType == 'image' ? Image.file(_selectedFile!) : const Center(child: Icon(Icons.video_collection, size: 50))),
          const Spacer(),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.image_outlined, color: Colors.green), onPressed: () => _pickFile(ImageSource.gallery, false)),
              IconButton(icon: const Icon(Icons.videocam_outlined, color: Colors.red), onPressed: () => _pickFile(ImageSource.gallery, true)),
              IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.blue), onPressed: () => _pickFile(ImageSource.camera, false)),
            ],
          )
        ],
      ),
    );
  }
}
