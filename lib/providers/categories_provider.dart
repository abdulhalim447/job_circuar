import 'package:flutter/material.dart';

class CategoriesProvider extends ChangeNotifier {
  // Hardcoded categories mapped with their corresponding asset icons
  final List<Map<String, dynamic>> _categories = [
    {'id': 39, 'name': 'হট জবস', 'iconPath': 'assets/icons/hot_job.png'},
    {
      'id': 6,
      'name': 'সরকারি চাকরি',
      'iconPath': 'assets/icons/govement_job.png',
    },
    {
      'id': 8,
      'name': 'ডিফেন্স চাকরি',
      'iconPath': 'assets/icons/defence_job.png',
    },
    {
      'id': 38,
      'name': 'বিশ্ববিদ্যালয় চাকরি',
      'iconPath': 'assets/icons/versity_job.png',
    },
    {
      'id': 7,
      'name': 'বেসরকারি চাকরি',
      'iconPath': 'assets/icons/non_govement_job.png',
    },
    {'id': 9, 'name': 'এনজিও চাকরি', 'iconPath': 'assets/icons/ngo_job.png'},
    {'id': 21, 'name': 'ব্যাংক চাকরি', 'iconPath': 'assets/icons/bank_job.png'},
    {
      'id': 1,
      'name': 'ঔষধ কোম্পানি চাকরি',
      'iconPath': 'assets/icons/company_job.png',
    },
    {
      'id': 10,
      'name': 'সাপ্তাহিক চাকরির পত্রিকা',
      'iconPath': 'assets/icons/weekly_job.png',
    },
    {
      'id': 11,
      'name': 'চাকরির পরীক্ষার সময়সূচী',
      'iconPath': 'assets/icons/job_exam_routinbe.png',
    },
    {
      'id': 12,
      'name': 'চাকরির পরীক্ষার ফলাফল',
      'iconPath': 'assets/icons/job_exam_result.png',
    },
    {
      'id': 45,
      'name': 'চাকরির প্রশ্ন ও সমাধান',
      'iconPath': 'assets/icons/job_questions_and_solutions.png',
    },
    {'id': 43, 'name': 'ক্যারিয়ার', 'iconPath': 'assets/icons/career.png'},
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
