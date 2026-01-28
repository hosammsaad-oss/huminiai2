import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'smart_purchase_filters.dart';
// استيراد الكلاسات الخاصة بك
// import 'path/to/smart_purchase_integration.dart';
// import 'path/to/integrated_purchase_analysis.dart';

/// صفحة عرض التحليل المالي الذكي
/// تتكامل مع SmartPurchaseIntegration و IntegratedPurchaseAnalysis
class SmartAccountsAnalysisPage extends StatefulWidget {
  final String userId;

  const SmartAccountsAnalysisPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<SmartAccountsAnalysisPage> createState() =>
      _SmartAccountsAnalysisPageState();
}

class _SmartAccountsAnalysisPageState extends State<SmartAccountsAnalysisPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late SmartPurchaseIntegration _smartPurchaseIntegration;
  late IntegratedPurchaseAnalysis _purchaseAnalysis;

  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic> _analysisData = {};
  List<TransactionData> _transactions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnalysis();
  }

  Future<void> _initializeAnalysis() async {
    try {
      setState(() => _isLoading = true);

      // تهيئة كائنات التحليل
      _smartPurchaseIntegration = SmartPurchaseIntegration(
        userId: widget.userId,
        firestore: _firestore,
      );

      _purchaseAnalysis = IntegratedPurchaseAnalysis(
        userId: widget.userId,
        firestore: _firestore,
      );

      // جلب البيانات من Firestore
      await _loadTransactionsData();
      await _performAnalysis();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في تحميل البيانات: ${e.toString()}';
        _isLoading = false;
      });
      print('Error initializing analysis: $e');
    }
  }

  Future<void> _loadTransactionsData() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(widget.userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      _transactions = snapshot.docs
          .map((doc) => TransactionData.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  Future<void> _performAnalysis() async {
    try {
      // تنفيذ التحليل الذكي
      final analysis = await _smartPurchaseIntegration.analyzeTransactions(
        _transactions,
      );

      // الحصول على النتائج المتكاملة
      final results = await _purchaseAnalysis.generateInsights(analysis);

      setState(() {
        _analysisData = results;
      });
    } catch (e) {
      print('Error performing analysis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التحليل المالي الذكي',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade600,
                Colors.purple.shade600,
              ],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeAnalysis,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _errorMessage.isNotEmpty
              ? _buildErrorWidget()
              : _buildMainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(),
        tooltip: 'إضافة معاملة جديدة',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue.shade600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل البيانات...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _initializeAnalysis,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الملخص المالي
              _buildFinancialSummaryCard(),
              const SizedBox(height: 24),

              // بطاقة الصحة المالية
              _buildFinancialHealthCard(),
              const SizedBox(height: 24),

              // رسم بياني توزيع المصروفات
              _buildExpenseDistributionChart(),
              const SizedBox(height: 24),

              // النصائح الذكية
              _buildSmartTipsCard(),
              const SizedBox(height: 24),

              // قائمة المعاملات الأخيرة
              _buildRecentTransactionsList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard() {
    final totalIncome = _analysisData['totalIncome'] ?? 0.0;
    final totalExpense = _analysisData['totalExpense'] ?? 0.0;
    final balance = totalIncome - totalExpense;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الملخص المالي',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  'الدخل',
                  totalIncome,
                  Colors.green,
                  Icons.trending_up,
                ),
                _buildSummaryItem(
                  'المصروفات',
                  totalExpense,
                  Colors.red,
                  Icons.trending_down,
                ),
                _buildSummaryItem(
                  'الرصيد',
                  balance,
                  balance >= 0 ? Colors.green : Colors.red,
                  Icons.account_balance_wallet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialHealthCard() {
   final healthScore = (_analysisData['healthScore'] ?? 0.0).toDouble();
    final healthStatus = _getHealthStatus(healthScore);
    final healthColor = _getHealthColor(healthScore);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الصحة المالية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: healthColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    healthStatus,
                    style: TextStyle(
                      color: healthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: healthScore / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(healthColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${healthScore.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseDistributionChart() {
    final categories = _analysisData['categoryDistribution'] as Map<String, double>? ?? {};

    if (categories.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'لا توجد بيانات كافية لعرض الرسم البياني',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    final pieChartSections = categories.entries
        .map((entry) => PieChartSectionData(
              value: entry.value,
              title: '${entry.value.toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              color: _getCategoryColor(entry.key),
            ))
        .toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع المصروفات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCategoryLegend(categories),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegend(Map<String, double> categories) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: categories.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getCategoryColor(entry.key),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key}: ${entry.value.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSmartTipsCard() {
    final tips = (_analysisData['smartTips'] as List<String>?) ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Colors.amber.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'نصائح ذكية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (tips.isEmpty)
              Text(
                'لا توجد نصائح متاحة حالياً',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              Column(
                children: tips
                    .map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 8, right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المعاملات الأخيرة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_transactions.isEmpty)
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'لا توجد معاملات',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return _buildTransactionTile(transaction);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionTile(TransactionData transaction) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          transaction.label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              transaction.category,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              DateFormat('dd/MM/yyyy').format(transaction.date),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} ${_formatCurrency(transaction.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة معاملة جديدة'),
        content: const Text(
          'سيتم فتح صفحة إضافة المعاملات',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // يمكنك هنا الانتقال إلى صفحة إضافة المعاملات
              // Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionPage()));
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // دوال مساعدة
  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ر.س';
  }

  String _getHealthStatus(double score) {
    if (score >= 80) return 'ممتاز';
    if (score >= 60) return 'جيد';
    if (score >= 40) return 'متوسط';
    return 'ضعيف';
  }

  Color _getHealthColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'food': Colors.orange,
      'transport': Colors.blue,
      'entertainment': Colors.purple,
      'utilities': Colors.yellow,
      'healthcare': Colors.red,
      'shopping': Colors.pink,
      'other': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }
}

/// نموذج بيانات المعاملة
class TransactionData {
  final String id;
  final String label;
  final String description;
  final double amount;
  final String type; // 'income' أو 'expense'
  final String category;
  final DateTime date;
  final List<String> tags;

  TransactionData({
    required this.id,
    required this.label,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.tags,
  });

  factory TransactionData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionData(
      id: doc.id,
      label: data['label'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'other',
      date: (data['date'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'date': Timestamp.fromDate(date),
      'tags': tags,
    };
  }
}

/// مثال على كيفية استخدام الصفحة في main.dart
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'Smart Accounts',
///       theme: ThemeData(
///         primarySwatch: Colors.blue,
///         useMaterial3: true,
///       ),
///       home: SmartAccountsAnalysisPage(
///         userId: FirebaseAuth.instance.currentUser?.uid ?? '',
///       ),
///     );
///   }
/// }
