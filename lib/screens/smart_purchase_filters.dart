import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'smart_purchase_analysis_page.dart';
/// فئة متقدمة لفلترة وتحليل المعاملات المالية
/// تتكامل مع SmartPurchaseIntegration و IntegratedPurchaseAnalysis
class SmartPurchaseFilters {
  final FirebaseFirestore _firestore;
  final String userId;

  SmartPurchaseFilters({
    required this.userId,
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  /// فلترة المعاملات حسب التاريخ
  Future<List<Map<String, dynamic>>> filterByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error filtering by date: $e');
      return [];
    }
  }

  /// فلترة المعاملات حسب النوع (دخل/مصروف)
  Future<List<Map<String, dynamic>>> filterByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('type', isEqualTo: type)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error filtering by type: $e');
      return [];
    }
  }

  /// فلترة المعاملات حسب التصنيف
  Future<List<Map<String, dynamic>>> filterByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error filtering by category: $e');
      return [];
    }
  }

  /// فلترة المعاملات حسب نطاق المبلغ
  Future<List<Map<String, dynamic>>> filterByAmountRange({
    required double minAmount,
    required double maxAmount,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('amount', isGreaterThanOrEqualTo: minAmount)
          .where('amount', isLessThanOrEqualTo: maxAmount)
          .orderBy('amount', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error filtering by amount: $e');
      return [];
    }
  }

  /// فلترة متقدمة مع معايير متعددة
  Future<List<Map<String, dynamic>>> advancedFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? category,
    double? minAmount,
    double? maxAmount,
    List<String>? tags,
    String? searchText,
  }) async {
    try {
      var query = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true);

      // تطبيق الفلاتر
      if (startDate != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (minAmount != null) {
        query = query.where('amount', isGreaterThanOrEqualTo: minAmount);
      }

      if (maxAmount != null) {
        query = query.where('amount', isLessThanOrEqualTo: maxAmount);
      }

      final snapshot = await query.get();
      var results = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // فلترة إضافية في الذاكرة
      if (tags != null && tags.isNotEmpty) {
        results = results.where((transaction) {
          final transactionTags = List<String>.from(transaction['tags'] ?? []);
          return tags.any((tag) => transactionTags.contains(tag));
        }).toList();
      }

      if (searchText != null && searchText.isNotEmpty) {
        results = results.where((transaction) {
          final label = (transaction['label'] ?? '').toString().toLowerCase();
          final description =
              (transaction['description'] ?? '').toString().toLowerCase();
          final search = searchText.toLowerCase();
          return label.contains(search) || description.contains(search);
        }).toList();
      }

      return results;
    } catch (e) {
      print('Error in advanced filter: $e');
      return [];
    }
  }

  /// حساب إجمالي المصروفات حسب التصنيف
  Future<Map<String, double>> getTotalByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await filterByDateRange(
        startDate: startDate ?? DateTime(DateTime.now().year, 1, 1),
        endDate: endDate ?? DateTime.now(),
      );

      final categoryTotals = <String, double>{};

      for (final transaction in transactions) {
        if (transaction['type'] == 'expense') {
          final category = transaction['category'] ?? 'other';
          final amount = (transaction['amount'] ?? 0).toDouble();
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        }
      }

      return categoryTotals;
    } catch (e) {
      print('Error calculating totals by category: $e');
      return {};
    }
  }

  /// حساب المتوسط الشهري للمصروفات
  Future<double> getMonthlyAverageExpense({
    int months = 3,
  }) async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - months, 1);
      final transactions = await filterByDateRange(
        startDate: startDate,
        endDate: now,
      );

      double totalExpense = 0;
      for (final transaction in transactions) {
        if (transaction['type'] == 'expense') {
          totalExpense += (transaction['amount'] ?? 0).toDouble();
        }
      }

      return totalExpense / months;
    } catch (e) {
      print('Error calculating monthly average: $e');
      return 0;
    }
  }

  /// الحصول على أعلى المصروفات
  Future<List<Map<String, dynamic>>> getTopExpenses({
    int limit = 10,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await filterByDateRange(
        startDate: startDate ?? DateTime(DateTime.now().year, 1, 1),
        endDate: endDate ?? DateTime.now(),
      );

      final expenses = transactions
          .where((t) => t['type'] == 'expense')
          .toList();

      expenses.sort((a, b) =>
          (b['amount'] ?? 0).compareTo(a['amount'] ?? 0));

      return expenses.take(limit).toList();
    } catch (e) {
      print('Error getting top expenses: $e');
      return [];
    }
  }

  /// تحليل الإنفاق الشهري
  Future<Map<String, double>> getMonthlySpendingAnalysis() async {
    try {
      final now = DateTime.now();
      final monthlyData = <String, double>{};

      for (int i = 11; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('MMM yyyy', 'ar').format(date);

        final startDate = DateTime(date.year, date.month, 1);
        final endDate = DateTime(date.year, date.month + 1, 0);

        final transactions = await filterByDateRange(
          startDate: startDate,
          endDate: endDate,
        );

        double monthlyTotal = 0;
        for (final transaction in transactions) {
          if (transaction['type'] == 'expense') {
            monthlyTotal += (transaction['amount'] ?? 0).toDouble();
          }
        }

        monthlyData[monthKey] = monthlyTotal;
      }

      return monthlyData;
    } catch (e) {
      print('Error analyzing monthly spending: $e');
      return {};
    }
  }

  /// اكتشاف الأنماط والعادات
  Future<Map<String, dynamic>> detectSpendingPatterns() async {
    try {
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month - 3, 1);

      final transactions = await filterByDateRange(
        startDate: startDate,
        endDate: now,
      );

      final patterns = <String, dynamic>{};

      // أكثر التصنيفات إنفاقاً
      final categoryTotals = <String, double>{};
      for (final transaction in transactions) {
        if (transaction['type'] == 'expense') {
          final category = transaction['category'] ?? 'other';
          final amount = (transaction['amount'] ?? 0).toDouble();
          categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
        }
      }

      patterns['topCategories'] = categoryTotals.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      // متوسط المعاملة
      double totalAmount = 0;
      int transactionCount = 0;
      for (final transaction in transactions) {
        totalAmount += (transaction['amount'] ?? 0).toDouble();
        transactionCount++;
      }

      patterns['averageTransaction'] =
          transactionCount > 0 ? totalAmount / transactionCount : 0;

      // أيام الإنفاق الأكثر
      final daySpending = <String, double>{};
      for (final transaction in transactions) {
        if (transaction['type'] == 'expense') {
          final date = (transaction['date'] as Timestamp).toDate();
          final dayName = DateFormat('EEEE', 'ar').format(date);
          final amount = (transaction['amount'] ?? 0).toDouble();
          daySpending[dayName] = (daySpending[dayName] ?? 0) + amount;
        }
      }

      patterns['spendingByDay'] = daySpending;

      return patterns;
    } catch (e) {
      print('Error detecting patterns: $e');
      return {};
    }
  }

  /// حساب نسبة الادخار
  Future<double> calculateSavingsRate({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final transactions = await filterByDateRange(
        startDate: startDate ?? DateTime(DateTime.now().year, 1, 1),
        endDate: endDate ?? DateTime.now(),
      );

      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        final amount = (transaction['amount'] ?? 0).toDouble();
        if (transaction['type'] == 'income') {
          totalIncome += amount;
        } else {
          totalExpense += amount;
        }
      }

      if (totalIncome == 0) return 0;

      final savings = totalIncome - totalExpense;
      return (savings / totalIncome) * 100;
    } catch (e) {
      print('Error calculating savings rate: $e');
      return 0;
    }
  }

  /// تصدير البيانات المفلترة
  Future<String> exportFilteredData({
    required List<Map<String, dynamic>> transactions,
    String format = 'csv', // csv أو json
  }) async {
    try {
      if (format == 'csv') {
        return _exportToCSV(transactions);
      } else if (format == 'json') {
        return _exportToJSON(transactions);
      }
      return '';
    } catch (e) {
      print('Error exporting data: $e');
      return '';
    }
  }

  String _exportToCSV(List<Map<String, dynamic>> transactions) {
    final buffer = StringBuffer();
    buffer.writeln('التاريخ,الوصف,النوع,التصنيف,المبلغ');

    for (final transaction in transactions) {
      final date = (transaction['date'] as Timestamp).toDate();
      final formattedDate = DateFormat('dd/MM/yyyy').format(date);
      final label = transaction['label'] ?? '';
      final type = transaction['type'] ?? '';
      final category = transaction['category'] ?? '';
      final amount = transaction['amount'] ?? 0;

      buffer.writeln('$formattedDate,$label,$type,$category,$amount');
    }

    return buffer.toString();
  }

  String _exportToJSON(List<Map<String, dynamic>> transactions) {
    final jsonList = transactions.map((transaction) {
      final date = (transaction['date'] as Timestamp).toDate();
      return {
        'date': date.toIso8601String(),
        'label': transaction['label'],
        'type': transaction['type'],
        'category': transaction['category'],
        'amount': transaction['amount'],
        'description': transaction['description'],
      };
    }).toList();

    return jsonList.toString();
  }
}

/// فئة للمساعدة في حساب المؤشرات المالية
class FinancialMetrics {
  final List<Map<String, dynamic>> transactions;

  FinancialMetrics(this.transactions);

  /// حساب الرصيد الكلي
  double getTotalBalance() {
    double balance = 0;
    for (final transaction in transactions) {
      final amount = (transaction['amount'] ?? 0).toDouble();
      if (transaction['type'] == 'income') {
        balance += amount;
      } else {
        balance -= amount;
      }
    }
    return balance;
  }

  /// حساب إجمالي الدخل
  double getTotalIncome() {
    return transactions
        .where((t) => t['type'] == 'income')
        .fold(0, (sum, t) => sum + (t['amount'] ?? 0).toDouble());
  }

  /// حساب إجمالي المصروفات
  double getTotalExpense() {
    return transactions
        .where((t) => t['type'] == 'expense')
        .fold(0, (sum, t) => sum + (t['amount'] ?? 0).toDouble());
  }

  /// حساب نسبة المصروفات من الدخل
  double getExpenseRatio() {
    final income = getTotalIncome();
    if (income == 0) return 0;
    return (getTotalExpense() / income) * 100;
  }

  /// حساب درجة الصحة المالية
  double getHealthScore() {
    final ratio = getExpenseRatio();
    if (ratio <= 50) return 100;
    if (ratio <= 70) return 80;
    if (ratio <= 90) return 60;
    if (ratio <= 100) return 40;
    return 20;
  }
}

// أضف هذا في نهاية ملف smart_purchase_filters.dart
class SmartPurchaseIntegration {
  final String userId;
  final FirebaseFirestore firestore;
  SmartPurchaseIntegration({required this.userId, required this.firestore});

  Future<Map<String, dynamic>> analyzeTransactions(List<TransactionData> transactions) async {
    double income = 0;
    double expense = 0;
    Map<String, double> categories = {};

    for (var t in transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
        categories[t.category] = (categories[t.category] ?? 0) + t.amount;
      }
    }
    return {'totalIncome': income, 'totalExpense': expense, 'categories': categories};
  }
}

class IntegratedPurchaseAnalysis {
  final String userId;
  final FirebaseFirestore firestore;
  IntegratedPurchaseAnalysis({required this.userId, required this.firestore});

  Future<Map<String, dynamic>> generateInsights(Map<String, dynamic> data) async {
    double inc = data['totalIncome'] ?? 0;
    double exp = data['totalExpense'] ?? 0;
    double score = inc > 0 ? ((inc - exp) / inc * 100).clamp(0, 100) : 0;
    
    return {
      'totalIncome': inc,
      'totalExpense': exp,
      'healthScore': score,
      'categoryDistribution': _calcPerc(data['categories'] ?? {}, exp),
      'smartTips': score < 50 ? ["⚠️ مصروفاتك مرتفعة"] : ["✅ وضعك المالي جيد"],
    };
  }

  Map<String, double> _calcPerc(Map<String, double> cats, double total) {
    if (total == 0) return {};
    return cats.map((k, v) => MapEntry(k, (v / total) * 100));
  }
}
