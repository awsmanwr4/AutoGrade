import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myproj/login.dart'; // عشان apiBase

class AssignmentSubmissionsPage extends StatefulWidget {
  final String assignmentId;
  final String assignmentTitle;

  const AssignmentSubmissionsPage({
    required this.assignmentId,
    required this.assignmentTitle,
    super.key,
  });

  @override
  State<AssignmentSubmissionsPage> createState() => _AssignmentSubmissionsPageState();
}

class _AssignmentSubmissionsPageState extends State<AssignmentSubmissionsPage> {
  List<dynamic> submissions = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final response = await http.get(Uri.parse("$apiBase/api/grading/submissions/${widget.assignmentId}"));
      if (response.statusCode == 200) {
        setState(() {
          submissions = jsonDecode(response.body);
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(widget.assignmentTitle),
        backgroundColor: const Color(0xFF0D1B3E),
        foregroundColor: Colors.white,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text("No submissions yet."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    final score = int.tryParse(sub['score']?.toString() ?? '0') ?? 0;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(sub['studentName'][0])),
                        title: Text(sub['studentName'] ?? 'Student'),
                        subtitle: Text("Score: $score%"),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }
}