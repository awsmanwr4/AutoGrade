import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myproj/login.dart'; 
import 'package:myproj/create_assignment.dart';
import 'package:myproj/assignment_submissions.dart';

// تعريف الـ API Base (تأكد إنه مطابق لمشروعك)
//const String apiBase = "http://your-api-url.com"; 
const String apiBase = "http://10.0.2.2:5217";

class TeacherDashboardPage extends StatefulWidget {
  final String teacherName;
  const TeacherDashboardPage({required this.teacherName, super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  Map<String, dynamic>? stats;
  List<dynamic> assignments = [];
  Map<String, dynamic>? enrollment;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (!mounted) return;
    setState(() => loading = true);
    try {
      final responses = await Future.wait([
        http.get(Uri.parse("$apiBase/api/grading/stats")),
        http.get(Uri.parse("$apiBase/api/assignments")),
        http.get(Uri.parse("$apiBase/api/auth/enrollment")),
      ]);

      if (!mounted) return;

      setState(() {
        if (responses[0].statusCode == 200) stats = jsonDecode(responses[0].body);
        if (responses[1].statusCode == 200) assignments = jsonDecode(responses[1].body) as List;
        if (responses[2].statusCode == 200) {
          final raw = jsonDecode(responses[2].body);
          enrollment = raw is Map ? Map<String, dynamic>.from(raw) : null;
        }
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  // ─── Logic Getters ───
  List<dynamic> get allSubmissions => (stats?['submissions'] as List?) ?? [];

  int get classAvg {
    if (allSubmissions.isEmpty) return 0;
    final total = allSubmissions.fold<int>(0, (sum, s) => sum + (int.tryParse(s['score']?.toString() ?? '0') ?? 0));
    return (total / allSubmissions.length).round();
  }

  int get passRate {
    if (allSubmissions.isEmpty) return 0;
    final passed = allSubmissions.where((s) => (int.tryParse(s['score']?.toString() ?? '0') ?? 0) >= 50).length;
    return (passed / allSubmissions.length * 100).round();
  }

  int get totalEnrolled {
    if (enrollment == null) return 0;
    return enrollment!.values.fold<int>(0, (sum, v) => sum + (int.tryParse(v.toString()) ?? 0));
  }

  // ─── UI Widgets ───

  Widget _statsRow() {
    final items = [
      {'label': 'Submissions', 'value': '${allSubmissions.length}', 'icon': Icons.description_outlined, 'color': const Color(0xFF1E63EB)},
      {'label': 'Class Avg', 'value': '$classAvg%', 'icon': Icons.bar_chart, 'color': Colors.green},
      {'label': 'Pass Rate', 'value': '$passRate%', 'icon': Icons.check_circle_outline, 'color': Colors.orange},
      {'label': 'Enrolled', 'value': '$totalEnrolled', 'icon': Icons.people_outline, 'color': Colors.teal},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final c = items[i];
          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(c['icon'] as IconData, color: c['color'] as Color, size: 24),
              const SizedBox(height: 6),
              Text(c['value'] as String, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: c['color'] as Color)),
              Text(c['label'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
          );
        },
      ),
    );
  }

  Widget _distributionCard() {
    final bands = [
      {'label': '90–100', 'min': 90, 'max': 101},
      {'label': '70–89', 'min': 70, 'max': 90},
      {'label': '50–69', 'min': 50, 'max': 70},
      {'label': '0–49', 'min': 0, 'max': 50},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Score Distribution", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          ...bands.map((band) {
            final count = allSubmissions.where((s) {
              final score = int.tryParse(s['score']?.toString() ?? '0') ?? 0;
              return score >= (band['min'] as int) && score < (band['max'] as int);
            }).length;
            final percent = allSubmissions.isEmpty ? 0.0 : count / allSubmissions.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(width: 60, child: Text(band['label'] as String, style: const TextStyle(fontSize: 12))),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[100],
                      color: (band['min'] as int) >= 70 ? Colors.blue : Colors.orange,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRiskSection() {
    final riskStudents = allSubmissions.where((s) {
      final score = int.tryParse(s['score']?.toString() ?? '0') ?? 0;
      return score < 50;
    }).toList();

    if (riskStudents.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text("Students Needing Attention ⚠️", 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent)),
        ),
        ...riskStudents.take(3).map((s) => Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.shade100)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.red.shade50, child: const Icon(Icons.person_outline, color: Colors.red)),
            title: Text(s['studentName'] ?? 'Student', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text("Latest Score: ${s['score']}%"),
            trailing: TextButton(onPressed: () {}, child: const Text("Notify", style: TextStyle(color: Colors.red))),
          ),
        )),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showExportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Generating Class Performance Report (Excel)..."), backgroundColor: Color(0xFF1E63EB)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D1B3E),
        foregroundColor: Colors.white,
        title: const Text("Teacher Dashboard", style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: _showExportDialog),
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchData,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _statsRow(),
                  const SizedBox(height: 24),
                  _distributionCard(),
                  const SizedBox(height: 24),
                  _buildRiskSection(),
                  const Text("Recent Activity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D1B3E))),
                  const SizedBox(height: 12),
                  if (assignments.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No assignments yet.")))
                  else
                    ...assignments.take(5).map((a) => _assignmentTile(a)).toList(),
                ],
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: "export_tag",
            backgroundColor: Colors.white,
            onPressed: _showExportDialog,
            child: const Icon(Icons.ios_share, color: Color(0xFF1E63EB)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: "add_tag",
            backgroundColor: const Color(0xFF1E63EB),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAssignmentPage())).then((_) => fetchData());
            },
            label: const Text("New Assignment", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      builder: (context, opacity, child) => Opacity(
        opacity: opacity,
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.blue.shade100, child: Text(widget.teacherName[0].toUpperCase())),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Welcome back,", style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text(widget.teacherName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _assignmentTile(dynamic a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.assignment_outlined, color: Color(0xFF1E63EB)),
        title: Text(a['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Due: ${a['dueDate'] ?? 'N/A'}"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignmentSubmissionsPage(
                assignmentId: a['id'].toString(),
                assignmentTitle: a['title'] ?? 'Assignment',
              ),
            ),
          );
        },
      ),
    );
  }
}