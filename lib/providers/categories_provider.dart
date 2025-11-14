import 'package:flutter/material.dart';

class CategoriesProvider extends ChangeNotifier {
  // Hardcoded categories (only IDs with available images)
  final List<Map<String, dynamic>> _categories = [
    {'id': 6, 'name': 'সরকারি চাকরি', 'icon': Icons.account_balance},
    {'id': 7, 'name': 'বেসরকারি চাকরি', 'icon': Icons.business},
    {'id': 8, 'name': 'ডিফেন্স চাকরি', 'icon': Icons.security},
    {'id': 9, 'name': 'ব্যাংক চাকরি', 'icon': Icons.account_balance_wallet},
    {'id': 10, 'name': 'এনজিও চাকরি', 'icon': Icons.volunteer_activism},
    {'id': 11, 'name': 'পরীক্ষার রুটিন', 'icon': Icons.calendar_today},
    {'id': 12, 'name': 'পরীক্ষার ফলাফল', 'icon': Icons.assessment},
    {'id': 21, 'name': 'ব্যাংক চাকরি', 'icon': Icons.account_balance_wallet},
    {'id': 1, 'name': 'ঔষধ কোম্পানি চাকরি', 'icon': Icons.medical_services},
    {'id': 0, 'name': 'সকল চাকরির খবর', 'icon': Icons.work},
  ];

  CategoriesProvider();

  List<Map<String, dynamic>> get categories => _categories;

  Map<String, dynamic>? getCategoryById(int id) {
    try {
      return _categories.firstWhere((cat) => cat['id'] == id);
    } catch (e) {
      return null;
    }
  }

  String getCategoryName(int id) {
    final category = getCategoryById(id);
    return category?['name'] ?? 'Unknown';
  }
}
