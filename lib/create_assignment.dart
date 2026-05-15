import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myproj/login.dart';

const List<String> _grades = [
  'Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6',
  'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'Grade 12',
];

class CreateAssignmentPage extends StatefulWidget {
  const CreateAssignmentPage({super.key});

  @override
  State<CreateAssignmentPage> createState() => _CreateAssignmentPageState();
}

class _CreateAssignmentPageState extends State<CreateAssignmentPage> {
  final _subjectCtrl = TextEditingController();
  String? _selectedGrade;
  DateTime? _deadline;
  final List<_QuestionEntry> _questions = [_QuestionEntry()];
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _subjectCtrl.dispose();
    for (final q in _questions) q.dispose();
    super.dispose();
  }

  void _addQuestion() => setState(() => _questions.add(_QuestionEntry()));

  void _removeQuestion(int i) {
    setState(() {
      _questions[i].dispose();
      _questions.removeAt(i);
    });
  }

  Future<void> _submit() async {
    if (_subjectCtrl.text.trim().isEmpty || _selectedGrade == null) {
      setState(() => _error = "Subject and grade are required.");
      return;
    }
    if (_questions.any((q) => q.question.text.trim().isEmpty || q.model.text.trim().isEmpty)) {
      setState(() => _error = "Every question needs both question text and model answer.");
      return;
    }
    setState(() { _loading = true; _error = ''; });

    try {
      final res = await http.post(
        Uri.parse("$apiBase/api/assignments"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "subject":  _subjectCtrl.text.trim(),
          "grade":    _selectedGrade,
          "deadline": _deadline?.toIso8601String(),
          "questions": _questions.map((q) => {
            "questionText": q.question.text.trim(),
            "modelAnswer":  q.model.text.trim(),
          }).toList(),
        }),
      );
      if ((res.statusCode == 200 || res.statusCode == 201) && mounted) {
        Navigator.pop(context);
      } else {
        setState(() { _error = "Failed to create assignment. Please try again."; _loading = false; });
      }
    } catch (_) {
      setState(() { _error = "Cannot connect to server."; _loading = false; });
    }
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() => _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B3E),
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: const Text("AutoGrade"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("New Assignment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
          const SizedBox(height: 16),

          // ── Subject / Grade / Deadline ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              TextField(
                controller: _subjectCtrl,
                decoration: InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: InputDecoration(
                  labelText: "Grade",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedGrade = v),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _deadline != null
                            ? "${_deadline!.day}/${_deadline!.month}/${_deadline!.year}  ${_deadline!.hour}:${_deadline!.minute.toString().padLeft(2, '0')}"
                            : "Deadline (optional)",
                        style: TextStyle(color: _deadline != null ? Colors.black87 : Colors.grey),
                      ),
                    ),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(Icons.close, size: 16, color: Colors.grey),
                      ),
                  ]),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Questions",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0D1B3E))),
            TextButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add, size: 16),
              label: const Text("Add Question"),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF1E63EB)),
            ),
          ]),
          const SizedBox(height: 8),

          // ── Questions ───────────────────────────────────────────────────────
          ...List.generate(_questions.length, (i) {
            final q = _questions[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text("Question ${i + 1}",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E63EB), fontWeight: FontWeight.bold)),
                  if (_questions.length > 1)
                    TextButton(
                      onPressed: () => _removeQuestion(i),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.red, minimumSize: Size.zero, padding: EdgeInsets.zero),
                      child: const Text("Remove", style: TextStyle(fontSize: 12)),
                    ),
                ]),
                const SizedBox(height: 8),
                TextField(
                  controller: q.question,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Question text",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: q.model,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Model answer (used by AI for grading)",
                    filled: true,
                    fillColor: const Color(0xFFF0F8FF),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
            );
          }),

          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error, style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E63EB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Assignment", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuestionEntry {
  final question = TextEditingController();
  final model    = TextEditingController();
  void dispose() { question.dispose(); model.dispose(); }
}
