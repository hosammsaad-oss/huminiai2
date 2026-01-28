import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';

// تعريف الحالة التي سنخزن فيها بيانات النشاط
class ActivityState {
  final String label;
  final IconData icon;
  final double acceleration;

  ActivityState({
    required this.label,
    required this.icon,
    required this.acceleration,
  });
}

// إنشاء الـ Notifier الذي يدير الحساس
class ActivityNotifier extends StateNotifier<ActivityState> {
  ActivityNotifier() : super(ActivityState(
    label: "جاري التحليل...", 
    icon: Icons.hourglass_empty, 
    acceleration: 0.0
  )) {
    _startListening();
  }

  void _startListening() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      // حساب القوة الإجمالية للحركة
      double acc = event.x.abs() + event.y.abs() + event.z.abs();
      
      String newLabel;
      IconData newIcon;

      if (acc < 12) {
        newLabel = "وضع الراحة 🧘";
        newIcon = Icons.self_improvement;
      } else if (acc < 25) {
        newLabel = "أنت تتحرك الآن 🚶";
        newIcon = Icons.directions_walk;
      } else {
        newLabel = "نشاط مرتفع! 🔥";
        newIcon = Icons.directions_run;
      }

      // تحديث الحالة فقط إذا تغير النشاط لتوفير الأداء
      if (newLabel != state.label || (acc - state.acceleration).abs() > 2) {
        state = ActivityState(label: newLabel, icon: newIcon, acceleration: acc);
      }
    });
  }
}

// المزود الذي سنستخدمه في أي واجهة
final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  return ActivityNotifier();
});