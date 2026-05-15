import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myproj/login.dart';

import 'stud_homeAnswer.dart'; // تأكد من أن ملف login.dart يحتوي على apiBase

class StudentDashboardPage extends StatefulWidget {
  final String studentName;
  final String studentGrade; // السطر ده عشان يحل مشكلة الـ Login

  const StudentDashboardPage({
    required this.studentName,
    this.studentGrade = '', // السطر ده عشان يستقبل الدرجة من صفحة اللوجن
    super.key,
  });

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  List<dynamic> _submissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // جلب البيانات الحقيقية فور فتح الصفحة
  }

  // دالة جلب البيانات من السيرفر
  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      // نبعت طلب للسيرفر لجلب تسليمات الطالب الحالية
      final response = await http.get(Uri.parse("$apiBase/api/grading/submissions"));
      
      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _submissions = jsonDecode(response.body) as List;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // حساب المتوسط الحسابي للدرجات الحقيقية
  double get _overallAverage {
    if (_submissions.isEmpty) return 0.0;
    double total = 0;
    for (var s in _submissions) {
      total += (int.tryParse(s['score']?.toString() ?? '0') ?? 0);
    }
    return total / _submissions.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D1B3E),
        title: const Text("Student Hub", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: _loading 
          ? const Center(child: CircularProgressIndicator()) 
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(),
                    const SizedBox(height: 25),
                    _buildMainStatsCard(), 
                    const SizedBox(height: 25),
                    _buildAIFeedbackCard(), 
                    const SizedBox(height: 25),
                    const Text("Your Assignments", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
                    const SizedBox(height: 15),
                    _buildSubmissionsList(), // هنا بتظهر المواد الحقيقية
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Level: ${widget.studentGrade}", 
              style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          Text(widget.studentName, 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
        ]),
        const CircleAvatar(
          radius: 25, 
          backgroundColor: Color(0xFF1E63EB), 
          child: Icon(Icons.person, color: Colors.white)
        ),
      ],
    );
  }

  Widget _buildMainStatsCard() {
    double avg = _overallAverage;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E63EB), Color(0xFF4B84F1)]),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Overall Grade", style: TextStyle(color: Colors.white70)),
            Text("${avg.toStringAsFixed(1)}%", 
                style: const TextStyle(color: Colors.white, fontSize: 35, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Real-time Analytics", 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
          ]),
          const Icon(Icons.auto_awesome, color: Colors.white24, size: 60),
        ],
      ),
    );
  }

  Widget _buildAIFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15), 
        border: Border.all(color: Colors.blue.shade50)
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Color(0xFF1E63EB), size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "AI Coach: Hello ${widget.studentName.split(' ')[0]}, your performance is being analyzed based on your recent submissions.",
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // عرض المواد والدرجات الحقيقية من السيرفر
  Widget _buildSubmissionsList() {
    if (_submissions.isEmpty) {
    return const Center(child: Text("No assignments found.")); // لو مفيش مواد لسه
  }

  return Column(
    children: _submissions.map((s) {
      int score = int.tryParse(s['score']?.toString() ?? '0') ?? 0;
      
      // هنا بنربط اسم المادة باللي جاي من الـ API
      String subject = s['subject'] ?? s['title'] ?? 'General Subject'; 

      return Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          // --- إضافة الـ onTap هنا ---
          onTap: () {
            // الانتقال لصفحة التسليم (HomePage) مع إرسال اسم المادة المحددة
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(subjectName: subject),
              ),
            );
          },
          // --------------------------
          leading: const Icon(Icons.book, color: Color(0xFF1E63EB)),
          title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Score: $score%"),
          trailing: Icon(
            score >= 50 ? Icons.check_circle : Icons.warning,
            color: score >= 50 ? Colors.green : Colors.red,
          ),
        ),
      );
    }).toList(),
  );
  }
}