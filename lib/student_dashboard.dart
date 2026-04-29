import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myproj/login.dart';

class StudentDashboardPage extends StatefulWidget {
  final String studentName;
  const StudentDashboardPage({required this.studentName});

  @override
  State<StudentDashboardPage> createState() => _StudentDashboardPageState();
}

class _StudentDashboardPageState extends State<StudentDashboardPage> {
  List<dynamic> submissions = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    try {
      final response = await http.get(Uri.parse("$apiBase/api/grading/submissions"));
      if (response.statusCode == 200) {
        final all = jsonDecode(response.body) as List;
        setState(() {
          submissions = all.where((s) =>
            (s['studentName'] as String).toLowerCase() == widget.studentName.toLowerCase()
          ).toList();
          loading = false;
        });
      } else {
        setState(() { error = 'Failed to load results'; loading = false; });
      }
    } catch (e) {
      setState(() { error = 'Cannot connect to server'; loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B3E),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("AutoGrade"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, ${widget.studentName}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E)),
            ),
            const SizedBox(height: 4),
            const Text("My Results", style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 16),

            if (loading)
              const Center(child: CircularProgressIndicator()),

            if (!loading && error.isNotEmpty)
              Center(child: Text(error, style: const TextStyle(color: Colors.red))),

            if (!loading && error.isEmpty && submissions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Text(
                    "No results yet.\nYour teacher hasn't graded any submissions for you.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),

            if (!loading && submissions.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final s = submissions[index];
                    final score = s['score'] as int;
                    final isPass = score >= 50;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(s['subject'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(s['question'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(s['createdAt']),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isPass ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "$score/100",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPass ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        ),
                        onTap: () => _showDetail(context, s),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '';
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return '';
    }
  }

  void _showDetail(BuildContext context, Map<String, dynamic> s) {
    final score = s['score'] as int;
    final isPass = score >= 50;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s['subject'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPass ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$score/100",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isPass ? Colors.green[800] : Colors.red[800]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailSection("Question", s['question']),
              _detailSection("Your Answer", s['studentAnswer']),
              _detailSection("Model Answer", s['modelAnswer']),
              _detailSection("Feedback", s['feedback']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailSection(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
