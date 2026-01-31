import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ملاحظة: يجب تهيئة Firebase هنا قبل تشغيل التطبيق في مشروعك الفعلي
  // await Firebase.initializeApp();
  runApp(const SmartAgentApp());
}

class SmartAgentApp extends StatelessWidget {
  const SmartAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart AI Agent',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6B4EFF),
        scaffoldBackgroundColor: const Color(0xFF0F0C29),
      ),
      home: const NewPurchaseScreen(),
    );
  }
}

// --- خدمة التنبيهات المركزية ---


// --- الصفحة الأولى: لوحة تحكم الوكيل الخارق ---
class NewPurchaseScreen extends StatefulWidget {
  const NewPurchaseScreen({super.key});
// ألوان يونيكورن الفاخرة
static const Color unicornPurple = Color(0xFF6B4EFF);
static const Color unicornNeon = Color(0xFF00F2FF);
static const Color unicornDark = Color(0xFF080B1A);
static const Color unicornGlass = Color(0xFF15192D);
  @override
  State<NewPurchaseScreen> createState() => _NewPurchaseScreenState();
}

class _NewPurchaseScreenState extends State<NewPurchaseScreen> {
  final TextEditingController _productController = TextEditingController();
  double _budget = 1000;
  bool _isSearching = false;
  bool _autoExecute = false;
  bool _isRadarEnabled = false;

  // دالة إطلاق الوكيل
  Future<void> _launchAgent() async {
    if (_productController.text.isEmpty) {
      _showSnackBar("أخبر الوكيل ماذا تريد أن يصطاد أولاً", Colors.redAccent);
      return;
    }

    setState(() => _isSearching = true);

    // محاكاة الاتصال بالسيرفر السحابي وفحص المواقع
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() => _isSearching = false);

    // إذا كان الرادار مفعلاً، نقوم ببرمجته في السيرفر أولاً
    if (_isRadarEnabled) {
      _registerRadarWithCloud();
      _showRadarConfirmation();
    } else {
      _navigateToResults();
    }
  }

  // محاكاة تسجيل الرادار في السيرفر (Cloud Backend)
  void _registerRadarWithCloud() {
    print("تم إرسال طلب المراقبة للسيرفر للمنتج: ${_productController.text}");
    // هنا يتم استدعاء الـ API الخاص بك (Python/Node.js)
  }

  void _navigateToResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingResultsScreen(
          productName: _productController.text,
          budget: _budget,
          isAuto: _autoExecute,
          isRadarActive: _isRadarEnabled,
        ),
      ),
    );
  }

  void _showRadarConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar, size: 60, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            Text("الرادار يعمل الآن 📡", style: GoogleFonts.tajawal(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              "سأقوم بمراقبة المتاجر على مدار الساعة. سأرسل لك تنبيهاً فور هبوط السعر لمستوى ${_budget.toInt()} ريال.",
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B4EFF)),
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToResults();
                },
                child: Text("اعتمد عليك، أرني النتائج الحالية ✅", style: GoogleFonts.tajawal()),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, textAlign: TextAlign.center, style: GoogleFonts.tajawal()), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("الوكيل الخارق AI ⚡", style: GoogleFonts.tajawal(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 35),
                _buildProductField(),
                const SizedBox(height: 30),
                _buildBudgetCard(),
                const SizedBox(height: 25),
                _buildAIFeatureSwitches(),
                const SizedBox(height: 50),
                _buildAnimatedLaunchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("نظام القنص الذكي نشط 🤖", style: GoogleFonts.tajawal(fontSize: 14, color: Colors.cyanAccent, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Text("ما هي مهمتي القادمة؟", style: GoogleFonts.tajawal(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildProductField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _productController,
        style: GoogleFonts.tajawal(color: Colors.white),
        decoration: InputDecoration(
          hintText: "اسم المنتج (مثلاً: Sony PS5)",
          hintStyle: GoogleFonts.tajawal(color: Colors.white38),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.cyanAccent),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("سقف الميزانية", style: GoogleFonts.tajawal(color: Colors.white70)),
              Text("${_budget.toInt()} ريال", style: GoogleFonts.poppins(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          Slider(
            value: _budget,
            min: 100,
            max: 20000,
            activeColor: Colors.cyanAccent,
            inactiveColor: Colors.white10,
            onChanged: (val) => setState(() => _budget = val),
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeatureSwitches() {
    return Column(
      children: [
        _buildFeatureToggle(
          title: "التنفيذ الآلي (Auto-Buy)",
          subtitle: "تجهيز السلة والدفع حتى خطوة التأكيد.",
          icon: Icons.bolt,
          value: _autoExecute,
          activeColor: const Color(0xFF6B4EFF),
          onChanged: (val) => setState(() => _autoExecute = val),
        ),
        const SizedBox(height: 15),
        _buildFeatureToggle(
          title: "رادار المراقبة (24/7 Radar)",
          subtitle: "مراقبة السعر في الخلفية وإرسال تنبيهات.",
          icon: Icons.radar,
          value: _isRadarEnabled,
          activeColor: Colors.cyanAccent,
          onChanged: (val) => setState(() => _isRadarEnabled = val),
        ),
      ],
    );
  }

  Widget _buildFeatureToggle({required String title, required String subtitle, required IconData icon, required bool value, required Color activeColor, required Function(bool) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: value ? activeColor.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: value ? activeColor : Colors.white10),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: value ? activeColor : Colors.white30),
        title: Text(title, style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: GoogleFonts.tajawal(fontSize: 11, color: Colors.white54)),
        value: value,
        activeThumbColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAnimatedLaunchButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6B4EFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 20,
          shadowColor: const Color(0xFF6B4EFF).withOpacity(0.4),
        ),
        onPressed: _isSearching ? null : _launchAgent,
        child: _isSearching 
          ? const CircularProgressIndicator(color: Colors.white)
          : Text("إطلاق الوكيل الذكي 🚀", style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// --- الصفحة الثانية: شاشة النتائج مع تحليل الذكاء الاصطناعي ---
class ShoppingResultsScreen extends StatelessWidget {
  final String productName;
  final double budget;
  final bool isAuto;
  final bool isRadarActive;

  const ShoppingResultsScreen({
    super.key,
    required this.productName,
    required this.budget,
    required this.isAuto,
    required this.isRadarActive,
  });

  @override
  Widget build(BuildContext context) {
    // محاكاة بيانات ذكية
    final List<Map<String, dynamic>> items = [
      {"store": "Amazon", "price": budget * 0.78, "trust": "98%", "note": "صيد ثمين! سعر تاريخي", "trend": "هابط 📉"},
      {"store": "Noon", "price": budget * 0.88, "trust": "91%", "note": "كوبون (OFF10) تم تطبيقه برمجياً", "trend": "مستقر ↔️"},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF0F0C29)),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFF1A1A2E),
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text("تحليل الوكيل لـ $productName", style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.bold)),
                  centerTitle: true,
                ),
              ),
              if (isRadarActive) _buildRadarStatusBar(),
              SliverPadding(
                padding: const EdgeInsets.only(top: 10),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildAdvancedResultCard(items[index]),
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarStatusBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.cyanAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.radar, color: Colors.cyanAccent, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                "الرادار يراقب السعر الآن في 5 متاجر مختلفة. ستصلك التنبيهات فوراً.",
                style: GoogleFonts.tajawal(fontSize: 12, color: Colors.cyanAccent, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedResultCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['store'], style: GoogleFonts.tajawal(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(item['note'], style: GoogleFonts.tajawal(fontSize: 12, color: Colors.amberAccent)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${item['price'].toInt()} ريال", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  Text("الاتجاه: ${item['trend']}", style: GoogleFonts.tajawal(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // نظام حماية المشتري (AI Guard)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                const Icon(Icons.verified_user, color: Colors.cyanAccent, size: 18),
                const SizedBox(width: 10),
                Text("تحليل المصداقية الذكي: ${item['trust']}", style: GoogleFonts.tajawal(fontSize: 12, color: Colors.white70)),
                const Spacer(),
                const Icon(Icons.info_outline, color: Colors.white24, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAuto ? Colors.amber : const Color(0xFF6B4EFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
              ),
              onPressed: () {
                // تنفيذ عملية الشراء أو الانتقال
              },
              child: Text(
                isAuto ? "تأكيد التنفيذ الآلي الذكي ⚡" : "عرض التفاصيل في المتجر",
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


