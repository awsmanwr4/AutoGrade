import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String score;
  final String feedback;
  final String studentAnswer;
  final String modelAnswer;
  final List<String> suggestions;

  const Home({
    super.key,
    required this.score,
    required this.feedback,
    required this.studentAnswer,
    required this.modelAnswer,
    this.suggestions = const [],
  });

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late TextEditingController answerController;
  late TextEditingController feedbackController;

  @override
  void initState() {
    super.initState();
    answerController = TextEditingController(text: widget.studentAnswer);
    feedbackController = TextEditingController(text: widget.feedback);
  }

  @override
  Widget build(BuildContext context) {
    int finalScore = int.tryParse(widget.score) ?? 0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Feedback', style: TextStyle(fontSize: 25, color: Colors.black)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings, color: Colors.black))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'STUDENT ANSWER',
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: answerController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: finalScore >= 50 ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.score}/100',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Text('Score', style: TextStyle(fontSize: 10, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text('MODEL ANSWER',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black54)),
              const SizedBox(height: 10),
              TextField(
                controller: TextEditingController(text: widget.modelAnswer),
                maxLines: 5,
                readOnly: true,
                style: TextStyle(fontSize: 14, color: Colors.blue.shade900, height: 1.4),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFE3F2FD),
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue.shade100),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text('Feedback Summary',
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Stack(
                children: [
                  TextField(
                    controller: feedbackController,
                    maxLines: 6,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const Positioned(right: 10, top: 10, child: Icon(Icons.copy, color: Colors.grey)),
                ],
              ),

              if (widget.suggestions.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Suggestions',
                    style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F8FF),
                    border: Border(left: BorderSide(color: Colors.blue.shade300, width: 4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.suggestions
                        .map((s) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("• ", style: TextStyle(fontSize: 14)),
                                  Expanded(child: Text(s, style: const TextStyle(fontSize: 14))),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Try Again', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('View Report', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
